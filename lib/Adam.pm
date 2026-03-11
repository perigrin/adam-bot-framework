package Adam;
# ABSTRACT: The patriarch of IRC Bots
our $VERSION = '1.004';
use MooseX::POE;
use namespace::autoclean;

use POE::Component::IRC::Common qw( :ALL );
use POE qw(
  Component::IRC::State
  Component::IRC::Plugin::PlugMan
  Component::IRC::Plugin::Connector
  Component::IRC::Plugin::ISupport
  Component::IRC::Plugin::NickReclaim
  Component::IRC::Plugin::BotAddressed
  Component::IRC::Plugin::AutoJoin
);

use MooseX::Aliases;
use Adam::Logger::Default;

with qw(
  MooseX::SimpleConfig
  MooseX::Getopt
);

=head1 SYNOPSIS

See the Synopsis in L<Moses>. Adam is not meant to be used directly.

=head1 DESCRIPTION

The Adam class implements an IRC bot based on L<POE::Component::IRC::State>,
L<Moose>, and L<MooseX::POE>. It supports two event loop modes: the default
L<POE> loop via C<run()>, and an L<IO::Async> mode via C<async()> that allows
integration with other L<IO::Async>-based components through
L<IO::Async::Loop::POE>.

Adam is not meant to be used directly — see L<Moses> for the declarative
sugar layer.

=cut

has logger => (
    does       => 'Adam::Logger::API',
    is         => 'ro',
    traits     => ['NoGetopt'],
    lazy_build => 1,
    handles    => 'Adam::Logger::API',
);

=attr logger

Logger object that implements the L<Adam::Logger::API> role. Defaults to
L<Adam::Logger::Default>.

=cut

sub _build_logger { Adam::Logger::Default->new() }

has nickname => (
    isa      => 'Str',
    reader   => 'get_nickname',
    alias    => 'nick',
    traits   => ['Getopt'],
    cmd_flag => 'nickname',
    required => 1,
    builder  => 'default_nickname',
);

=attr nickname

The IRC nickname for the bot. Defaults to the package name. Required.

=cut

sub default_nickname { $_[0]->meta->name }

has server => (
    isa      => 'Str',
    reader   => 'get_server',
    traits   => ['Getopt'],
    cmd_flag => 'server',
    required => 1,
    builder  => 'default_server',
);

=attr server

The IRC server to connect to. Defaults to C<irc.perl.org>. Required.

=cut

sub default_server { 'irc.perl.org' }

has port => (
    isa      => 'Int',
    reader   => 'get_port',
    traits   => ['Getopt'],
    cmd_flag => 'port',
    required => 1,
    builder  => 'default_port',
);

=attr port

The port for the IRC server. Defaults to C<6667>.

=cut

sub default_port { 6667 }

has channels => (
    isa        => 'ArrayRef',
    reader     => 'get_channels',
    traits     => ['Getopt'],
    cmd_flag   => 'channels',
    builder    => 'default_channels',
    auto_deref => 1,
);

=attr channels

IRC channels to connect to. ArrayRef of channel names.

=cut

sub default_channels { [] }

has owner => (
    isa      => 'Str',
    accessor => 'get_owner',
    traits   => ['Getopt'],
    cmd_flag => 'owner',
    builder  => 'default_owner',
);

=attr owner

The hostmask of the owner of the bot. The owner can control the bot's plugins
through IRC using the L<POE::Component::IRC::Plugin::PlugMan> interface.

=cut

sub default_owner { 'perigrin!~perigrin@217.168.150.167' }

has username => (
    isa      => 'Str',
    accessor => 'get_username',
    traits   => ['Getopt'],
    cmd_flag => 'username',
    builder  => 'default_username',
);

=attr username

The username to use for IRC connection. Defaults to C<adam>.

=cut

sub default_username { 'adam' }

has password => (
    isa      => 'Str',
    accessor => 'get_password',
    traits   => ['Getopt'],
    cmd_flag => 'password',
    builder  => 'default_password',
);

=attr password

The server password to use for IRC connection. Defaults to empty string.

=cut

sub default_password { '' }

has flood => (
    isa      => 'Bool',
    reader   => 'can_flood',
    traits   => ['Getopt'],
    cmd_flag => 'flood',
    builder  => 'default_flood',
);

=attr flood

Disable flood protection. Defaults to C<0> (false).

=cut

sub default_flood { 0 }

has plugins => (
    isa        => 'HashRef',
    traits     => [ 'Hash', 'NoGetopt' ],
    lazy       => 1,
    auto_deref => 1,
    builder    => 'default_plugins',
    handles    => {
        plugin_names => 'keys',
        get_plugin   => 'get',
        has_plugins  => 'count'
    }
);

=attr plugins

A HashRef of plugins associated with the IRC bot. See L<Moses::Plugin> for more
details.

=cut

sub core_plugins {
    return {
        'Core_Connector'    => 'POE::Component::IRC::Plugin::Connector',
        'Core_BotAddressed' => 'POE::Component::IRC::Plugin::BotAddressed',
        'Core_AutoJoin'     => POE::Component::IRC::Plugin::AutoJoin->new(
            Channels => { map { $_ => '' } @{ $_[0]->get_channels } },
        ),
        'Core_NickReclaim' =>
          POE::Component::IRC::Plugin::NickReclaim->new( poll => 30 ),
    };
}

=method core_plugins

Returns the core plugins that are loaded by default.

=cut

sub custom_plugins { {} }

=method custom_plugins

Returns custom plugins to be loaded. Override this in subclasses.

=cut

sub default_plugins {
    return { %{ $_[0]->core_plugins }, %{ $_[0]->custom_plugins } };
}

=method default_plugins

Returns all plugins (core and custom) to be loaded.

=cut

has plugin_manager => (
    isa        => 'POE::Component::IRC::Plugin::PlugMan',
    is         => 'ro',
    lazy_build => 1,
);

=attr plugin_manager

The L<POE::Component::IRC::Plugin::PlugMan> instance for managing plugins.

=cut

sub _build_plugin_manager {
    POE::Component::IRC::Plugin::PlugMan->new(
        botowner => $_[0]->get_owner,
        debug    => 1
    );
}

before 'START' => sub {
    my ($self) = @_;
    $self->plugin_add( 'PlugMan' => $self->plugin_manager );
};

has poco_irc_args => (
    isa      => 'HashRef',
    accessor => 'get_poco_irc_args',
    traits   => [ 'Hash', 'Getopt' ],
    cmd_flag => 'extra_args',
    builder  => 'default_poco_irc_args',
);

=attr poco_irc_args

A HashRef of extra arguments to pass to the IRC component constructor.

=cut

sub default_poco_irc_args {
    {};
}

has poco_irc_options => (
    isa      => 'HashRef',
    accessor => 'get_poco_irc_options',
    traits   => [ 'Hash', 'Getopt' ],
    cmd_flag => 'extra_args',
    builder  => 'default_poco_irc_options',
);

=attr poco_irc_options

A HashRef of options to pass to the IRC component. Defaults to C<< { trace => 0 } >>.

=cut

sub default_poco_irc_options { { trace => 0 } }

has _irc => (
    isa        => 'POE::Component::IRC',
    accessor   => 'irc',
    lazy_build => 1,
    handles    => {
        irc_session_id => 'session_id',
        server_name    => 'server_name',
        plugin_add     => 'plugin_add',
    }
);

sub _build__irc {
	my $self = shift;
    POE::Component::IRC::State->spawn(
        Nick     => $self->get_nickname,
        Server   => $self->get_server,
        Port     => $self->get_port,
        Ircname  => $self->get_nickname,
        Options  => $self->get_poco_irc_options,
        Flood    => $self->can_flood,
        Username => $self->get_username,
        Password => $self->get_password,
		%{ $self->get_poco_irc_args },
    );
}

sub privmsg {
    my $self = shift;
    POE::Kernel->post( $self->irc_session_id => privmsg => @_ );
}

=method privmsg

    $bot->privmsg($who, $what);

Send message C<$what> as a private message to C<$who>, a channel or nick.

=cut

sub START {
    my ( $self, $heap ) = @_[ OBJECT, HEAP ];
    $poe_kernel->post( $self->irc_session_id => register => 'all' );
    $poe_kernel->post( $self->irc_session_id => connect  => {} );
    $self->info( 'connecting to ' . $self->get_server . ':' . $self->get_port );
    return;
}

sub load_plugin {
    my ( $self, $name, $plugin ) = @_;
    $self->plugin_manager->load( $name => $plugin, bot => $self );
}

=method load_plugin

    $bot->load_plugin($name, $plugin);

Load a plugin with the given name.

=cut

event irc_plugin_add => sub {
    my ( $self, $desc, $plugin ) = @_[ OBJECT, ARG0, ARG1 ];
    $self->info("loaded plugin: $desc");
    if ( $desc eq 'PlugMan' ) {
        $self->debug("loading other plugins");
        for my $name ( sort $self->plugin_names ) {
            $self->debug("loading $name");
            $plugin = $self->get_plugin($name);
            $self->load_plugin( $name => $plugin );
        }
    }
};

event irc_connected => sub {
    my ( $self, $sender ) = @_[ OBJECT, SENDER ];
    $self->info( "connected to " . $self->get_server . ':' . $self->get_port );
    return;
};

# We registered for all events, this will produce some debug info.
sub DEFAULT {
    my ( $self, $event, $args ) = @_[ OBJECT, ARG0 .. $#_ ];
    my @output = ("$event: ");

    foreach my $arg (@$args) {
        if ( ref($arg) eq ' ARRAY ' ) {
            push( @output, "[" . join( " ,", @$arg ) . "]" );
        }
        else {
            push( @output, "'$arg' " );
        }
    }
    $self->debug( join ' ', @output );
    return 0;
}

sub run {
    $_[0]->new_with_options unless blessed $_[0];
    POE::Kernel->run;
}

=method run

    MyBot->run;
    # or
    $bot->run;

Start the IRC bot using the POE event loop. This method also works as a
class method and will instantiate the bot if called as such.

=cut

has _loop => (
    is        => 'rw',
    traits    => ['NoGetopt'],
    predicate => 'has_loop',
);

sub async {
    my $self = shift;
    require IO::Async::Loop::POE;
    $self = $self->new_with_options unless blessed $self;
    my $loop = IO::Async::Loop::POE->new();
    $self->_loop($loop);
    $loop->run;
}

=method async

    MyBot->async;
    # or
    $bot->async;

Start the IRC bot using IO::Async as the event loop. This allows you to
integrate the bot with other IO::Async-based components. Requires
L<IO::Async::Loop::POE> to be installed.

This method also works as a class method and will instantiate the bot
if called as such.

=cut

sub stop {
    my $self = shift;
    if ($self->has_loop) {
        $self->_loop->stop;
    } else {
        POE::Kernel->stop;
    }
}

=method stop

    $bot->stop;

Stop the bot's event loop. Works with both POE and IO::Async modes.

=cut

1;
