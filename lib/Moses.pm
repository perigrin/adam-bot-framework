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

Moses - A class to ...

=head1 VERSION

This documentation refers to version 0.01.

=head1 SYNOPSIS

use Moses;

=head1 DESCRIPTION

The Moses class implements ...

=head1 SUBROUTINES / METHODS

=head2 init_meta

Parameters:
    none

Insert description of subroutine here...

=head2 nickname

Parameters:
    caller
    name

Insert description of subroutine here...

=head2 server

Parameters:
    caller
    name

Insert description of subroutine here...

=head2 port

Parameters:
    caller
    port

Insert description of subroutine here...

=head2 channels

Parameters:
    none

Insert description of subroutine here...

=head2 plugins

Parameters:
    none

Insert description of subroutine here...

=head1 DEPENDENCIES

Modules used, version dependencies, core yes/no

Moose::Exporter

Adam

POE

=head1 NOTES

...

=head1 BUGS AND LIMITATIONS

None known currently, please email the author if you find any.

=head1 AUTHOR

Chris Prather (perigrin@domain.tld)

=head1 LICENCE

Copyright 2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
