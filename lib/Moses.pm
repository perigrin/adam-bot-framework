package Moses;
use MooseX::POE ();
use Moose::Exporter;
use Adam;

our $VERSION = $Adam::VERSION;

Moose::Exporter->setup_import_methods(
    with_caller => [qw(nickname server port channels plugins)],
    also        => [qw(MooseX::POE)],
);

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

sub server {
    my ( $caller, $name ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_server' => sub { return $name } );
}

sub port {
    my ( $caller, $port ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_port' => sub { return $port } );
}

sub channels {
    my ( $caller, @channels ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_channels' => sub { return \@channels } );
}

sub plugins {
    my ( $caller, %plugins ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'custom_plugins' => sub { return \%plugins } );
}

1;
__END__

=head1 NAME

Moses - A framework for building IRC bots quickly and easily.

=head1 VERSION

This documentation refers to version 0.04.

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

	__PACKAGE__->run unless caller;

=head1 DESCRIPTION

Moses is some declarative sugar for building an IRC bot based on the
L<Adam|Adam> IRC Bot. Moses is designed to minimize the amount of work you
have to do to make an IRC bot functional, and to make the process as
declarative as possible. 

=head1 FUNCTIONS

=head2 nickname (Str $name)

Insert description of subroutine here...

=head2 server (Str $server)

Insert description of subroutine here...

=head2 port (Int $port)

Insert description of subroutine here...

=head2 channels (@channels)

Insert description of subroutine here...

=head2 plugins (@plugins)
 
Insert description of subroutine here...

=head1 DEPENDENCIES

The same dependencies as L<Adam|Adam>. 

MooseX::POE, namespace::autoclean, MooseX::Alias, POE::Component::IRC,
MooseX::Getopt, MooseX::SimpleConfig, MooseX::LogDispatch

=head1 BUGS AND LIMITATIONS

None known currently, please email the author if you find any.

=head1 AUTHOR

Chris Prather (chris@prather.org)

=head1 LICENCE

Copyright 2007-2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
