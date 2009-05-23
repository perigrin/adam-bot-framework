package Adam;
our $VERSION = '0.0.3';

use MooseX::POE;

use POE::Component::IRC::Common qw( :ALL );

use MooseX::AttributeHelpers;
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

with qw(
  MooseX::SimpleConfig
  MooseX::Getopt
  MooseX::LogDispatch::Levels
);

has logger => (
    metaclass  => 'NoGetopt',
    isa        => 'Log::Dispatch::Config',
    is         => 'rw',
    lazy_build => 1,
);

has _nickname => (
    metaclass => 'MooseX::Getopt::Meta::Attribute',
    cmd_flag  => 'nickname',
    isa       => 'Str',
    is        => 'ro',
    required  => 1,
    builder   => 'default_nickname',
);

sub default_nickname { $_[0]->meta->name }
sub nick             { shift->_nickname(@_) }

has _server => (
    metaclass => 'MooseX::Getopt::Meta::Attribute',
    cmd_flag  => 'server',
    isa       => 'Str',
    is        => 'ro',
    required  => 1,
    builder   => 'default_server',
);

sub default_server { 'irc.perl.org' }

has _port => (
    metaclass => 'MooseX::Getopt::Meta::Attribute',
    cmd_flag  => 'port',
    isa       => 'Int',
    is        => 'ro',
    required  => 1,
    builder   => 'default_port',
);

sub default_port { 6667 }

has _channels => (
    metaclass  => 'MooseX::Getopt::Meta::Attribute',
    cmd_flag   => 'channels',
    isa        => 'ArrayRef',
    is         => 'ro',
    builder    => 'default_channels',
    auto_deref => 1,
);

sub default_channels { [ ] }

has _owner => (
    accessor  => 'owner',
    metaclass => 'MooseX::Getopt::Meta::Attribute',
    cmd_flag  => 'owner',
    isa       => 'Str',
    builder   => 'default_owner',
);

sub default_owner { 'perigrin!~perigrin@217.168.150.167' }

has _flood => (
    accessor  => 'flood',
    metaclass => 'MooseX::Getopt::Meta::Attribute',
    cmd_flag  => 'flood',
    isa       => 'Bool',
    builder   => 'default_flood',
);

sub default_flood { 0 }

has _plugins => (
    metaclass  => 'Collection::Hash',
    isa        => 'HashRef',
    lazy_build => 1,
    auto_deref => 1,
    accessor   => 'plugins',
    builder    => 'default_plugins',
    provides   => {
        keys  => 'plugin_names',
        get   => 'get_plugin',
        count => 'has_plugins',
    }
);

sub core_plugins {
    return {
        'Core_Connector'    => 'POE::Component::IRC::Plugin::Connector',
        'Core_BotAddressed' => 'POE::Component::IRC::Plugin::BotAddressed',
        'Core_AutoJoin'     => POE::Component::IRC::Plugin::AutoJoin->new(
            Channels => { map { $_ => '' } @{ $_[0]->_channels } },
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
        botowner => $self->owner,
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
        Nick    => $_[0]->_nickname,
        Server  => $_[0]->_server,
        Port    => $_[0]->_port,
        Ircname => $_[0]->_nickname,
        Options => { trace => 0 },
        Flood   => $_[0]->flood,
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
    $self->info( 'connecting to ' . $self->_server . ':' . $self->_port );
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
    $self->info( "connected to " . $self->_server . ':' . $self->_port );
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

no MooseX::POE
  ;    # unimport Moose's keywords so they won't accidentally become methods
1;     # Magic true value required at end of module
__END__

=head1 NAME

Adam - The Progenitor of IRC Bots

=head1 VERSION

This document describes Adam version 0.0.3

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

=head1 DESCRIPTION

Adam is the basis for all the Adam/Moses IRC bots.

=head1 INTERFACE 


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES

Moose, MooseX::POE, MooseX::Getopt, MooseX::SimpleConfig, MooseX::LogDispatch,
POE, POE::Component::IRC

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<chris@prather.org>.

=head1 AUTHOR

Chris Prather  C<< <chris@prather.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007 Chris Prather  C<< <chris@prather.org> >>, Some rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
