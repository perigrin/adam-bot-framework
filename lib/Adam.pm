package Adam;
our $VERSION = '0.04';
use MooseX::POE;
use namespace::autoclean;

use POE::Component::IRC::Common qw( :ALL );
use POE qw(
  Component::IRC::State
  Component::IRC::Plugin::PlugMan
  Component::IRC::Plugin::Connector
  Component::IRC::Plugin::Console
  Component::IRC::Plugin::ISupport
  Component::IRC::Plugin::NickReclaim
  Component::IRC::Plugin::BotAddressed
  Component::IRC::Plugin::AutoJoin
);

use MooseX::Aliases;

with qw(
  MooseX::SimpleConfig
  MooseX::Getopt
  MooseX::LogDispatch::Levels
);

has logger => (
    isa        => 'Log::Dispatch::Config',
    is         => 'rw',
    traits     => ['NoGetopt'],
    lazy_build => 1,
);

has nickname => (
    isa      => 'Str',
    reader   => 'get_nickname',
    alias    => 'nick',
    traits   => ['Getopt'],
    cmd_flag => 'nickname',
    required => 1,
    builder  => 'default_nickname',
);

sub default_nickname { $_[0]->meta->name }

has server => (
    isa      => 'Str',
    reader   => 'get_server',
    traits   => ['Getopt'],
    cmd_flag => 'server',
    required => 1,
    builder  => 'default_server',
);

sub default_server { 'irc.perl.org' }

has port => (
    isa      => 'Int',
    reader   => 'get_port',
    traits   => ['Getopt'],
    cmd_flag => 'port',
    required => 1,
    builder  => 'default_port',
);

sub default_port { 6667 }

has channels => (
    isa        => 'ArrayRef',
    reader     => 'get_channels',
    traits     => ['Getopt'],
    cmd_flag   => 'channels',
    builder    => 'default_channels',
    auto_deref => 1,
);

sub default_channels { [] }

has owner => (
    isa      => 'Str',
    accessor => 'get_owner',
    traits   => ['Getopt'],
    cmd_flag => 'owner',
    builder  => 'default_owner',
);

sub default_owner { 'perigrin!~perigrin@217.168.150.167' }

has flood => (
    isa     => 'Bool',
    reader  => 'can_flood',
    builder => 'default_flood',
);

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

sub core_plugins {
    return {
        'Core_Connector'    => 'POE::Component::IRC::Plugin::Connector',
        'Core_BotAddressed' => 'POE::Component::IRC::Plugin::BotAddressed',
        'Core_AutoJoin'     => POE::Component::IRC::Plugin::AutoJoin->new(
            Channels => { map { $_ => '' } @{ $_[0]->get_channels } },
        ),

# 'Core_Console'      => POE::Component::IRC::Plugin::Console->new(
#    bindport => 6669,
#    password => 'super^star',
#  ),
# 'Core_NickReclaim'  => POE::Component::IRC::Plugin::NickReclaim->new(poll => 30),

    };
}

sub custom_plugins { {} }

sub default_plugins {
    return { %{ $_[0]->core_plugins }, %{ $_[0]->custom_plugins } };
}

before 'START' => sub {
    my ($self) = @_;
    my $pm = POE::Component::IRC::Plugin::PlugMan->new(
        botowner => $self->get_owner,
        debug    => 1
    );
    $self->plugin_add( 'PlugMan' => $pm );
};

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
    POE::Component::IRC::State->spawn(
        Nick    => $_[0]->get_nickname,
        Server  => $_[0]->get_server,
        Port    => $_[0]->get_port,
        Ircname => $_[0]->get_nickname,
        Options => { trace => 0 },
        Flood   => $_[0]->can_flood,
    );
}

sub privmsg {
    my $self = shift;
    POE::Kernel->post( $self->irc_session_id => privmsg => @_ );
}

sub START {
    my ( $self, $heap ) = @_[ OBJECT, HEAP ];

    # We get the session ID of the component from the object
    # and register and connect to the specified server.
    $poe_kernel->post( $self->irc_session_id => register => 'all' );
    $poe_kernel->post( $self->irc_session_id => connect  => {} );
    $self->info( 'connecting to ' . $self->get_server . ':' . $self->get_port );
    return;
}

event irc_plugin_add => sub {
    my ( $self, $desc, $plugin ) = @_[ OBJECT, ARG0, ARG1 ];
    $self->info("loaded plugin: $desc");
    if ( $desc eq 'PlugMan' ) {
        my $manager = $plugin;
        $self->debug("loading other plugins");
        for my $name ( sort $self->plugin_names ) {
            $self->debug("loading $name");
            $plugin = $self->get_plugin($name);
            $manager->load( $name => $plugin, bot => $self );
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

1;    # Magic true value required at end of module
__END__

=head1 NAME

Adam - The Progenitor of IRC Bots

=head1 VERSION

This document describes Adam version 0.04

=head1 SYNOPSIS

	package Echo;
	use Moose;
	extends qw(Adam);

	event irc_bot_addressed => sub {
	    my ( $self, $nickstr, $channel, $msg ) = @_[ OBJECT, ARG0, ARG1, ARG2 ];
	    my ($nick) = split /!/, $nickstr;
	    $self->privmsg( $channel => "$nick: $msg" );
	};

	__PACKAGE__->run;

	no Moose;
	1;
	__END__


or using the Moses sugar layer

	package Echo;
	use Moses;
	use namespace::autoclean;
	
	event irc_bot_addressed => sub {
	    my ( $self, $nickstr, $channel, $msg ) = @_[ OBJECT, ARG0, ARG1, ARG2 ];
	    my ($nick) = split /!/, $nickstr;
	    $self->privmsg( $channel => "$nick: $msg" );
	};

	Echo->run

=head1 DESCRIPTION

Adam/Moses is a bot framework developed based on the last seven years of
POE::Component::IRC bots I've built.


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES

Moose, MooseX::POE, MooseX::Getopt, MooseX::SimpleConfig, MooseX::LogDispatch,
POE, POE::Component::IRC

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to C<chris@prather.org>.

=head1 AUTHOR

Chris Prather  C<< <chris@prather.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007 Chris Prather  C<< <chris@prather.org> >>, Some rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
