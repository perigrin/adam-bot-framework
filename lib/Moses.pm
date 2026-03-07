package Moses;
# ABSTRACT: A framework for building IRC bots quickly and easily.

use MooseX::POE ();
use Moose::Exporter;
use Adam;

Moose::Exporter->setup_import_methods(
    with_caller => [
        qw(
          nickname
          server
          port
          channels
          plugins
          username
          owner
          flood
          password
          poco_irc_args
          poco_irc_options
          )
    ],
    also => [qw(MooseX::POE)],
);

=head1 SYNOPSIS

    package SampleBot;
    use Moses;
    use namespace::autoclean;

    server 'irc.perl.org';
    nickname 'sample-bot';
    channels '#bots';

    has message => (
        isa     => 'Str',
        is      => 'rw',
        default => 'Hello',
    );

    event irc_bot_addressed => sub {
        my ( $self, $nickstr, $channel, $msg ) = @_[ OBJECT, ARG0, ARG1, ARG2 ];
        my ($nick) = split /!/, $nickstr;
        $self->privmsg( $channel => "$nick: ${ \$self->message }" );
    };

    # Run with POE (default)
    __PACKAGE__->run unless caller;

    # Or run with IO::Async (requires IO::Async::Loop::POE)
    # __PACKAGE__->async unless caller;

=head1 DESCRIPTION

Moses is declarative sugar for building IRC bots based on the L<Adam> IRC Bot.
Moses is designed to minimize the amount of work you have to do to make an IRC
bot functional, and to make the process as declarative as possible.

=cut

sub init_meta {
    my ( $class, %args ) = @_;

    my $for = $args{for_class};
    eval qq{
        package $for;
        use POE;
        use POE::Component::IRC::Common qw( :ALL );
    };

    Moose->init_meta(
        for_class  => $for,
        base_class => 'Adam'
    );
}

sub nickname {
    my ( $caller, $name ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_nickname' => sub { return $name } );
}

=func nickname

    nickname 'sample-bot';

Set the nickname for the bot. Defaults to the current package name.

=cut

sub server {
    my ( $caller, $name ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_server' => sub { return $name } );
}

=func server

    server 'irc.perl.org';

Set the IRC server for the bot to connect to.

=cut

sub port {
    my ( $caller, $port ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_port' => sub { return $port } );
}

=func port

    port 6667;

Set the port for the bot's server. Defaults to C<6667>.

=cut

sub channels {
    my ( $caller, @channels ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_channels' => sub { return \@channels } );
}

=func channels

    channels '#bots', '#perl';

Supply a list of channels for the bot to join upon connecting.

=cut

sub plugins {
    my ( $caller, %plugins ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'custom_plugins' => sub { return \%plugins } );
}

=func plugins

    plugins MyPlugin => 'MyBot::Plugin::Foo';

Extra L<POE::Component::IRC::Plugin> objects or class names to load into the bot.

=cut

sub username {
    my ( $caller, $username ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_username' => sub { return $username } );
}

=func username

    username 'mybot';

The username to use for IRC connection.

=cut

sub password {
    my ( $caller, $password ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_password' => sub { return $password } );
}

=func password

    password 'secret';

The server password to use for IRC connection.

=cut

sub flood {
    my ( $caller, $flood ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_flood' => sub { return $flood } );
}

=func flood

    flood 1;

Disable flood protection. Defaults to false.

=cut

sub owner {
    my ( $caller, $owner ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_owner' => sub { return $owner } );
}

=func owner

    owner 'nick!user@host';

The hostmask of the owner of the bot. The owner can control the bot's plugins
through IRC using the L<POE::Component::IRC::Plugin::PlugMan> interface.

=cut

sub poco_irc_args {
    my ( $caller, %extra_args ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_poco_irc_args' => sub { return \%extra_args }
    );
}

=func poco_irc_args

    poco_irc_args LocalAddr => '127.0.0.1';

Extra arguments to pass to the IRC component constructor.

=cut

sub poco_irc_options {
    my ( $caller, %options ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_poco_irc_options' => sub { return \%options }
    );
}

=func poco_irc_options

    poco_irc_options trace => 1;

Options to pass to the IRC component constructor.

=cut

1;
