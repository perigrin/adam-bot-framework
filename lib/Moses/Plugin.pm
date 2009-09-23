package Moses::Plugin;
use Moose       ();
use MooseX::POE ();
use Moose::Exporter;
use Adam::Plugin;

our $VERSION = $Adam::VERSION;

Moose::Exporter->setup_import_methods(
    with_caller => [qw(events)],
    also        => [qw(Moose)],
);

sub init_meta {
    my ( $class, %args ) = @_;

    my $for = $args{for_class};
    eval qq{
        package $for; 
        use POE;
        use POE::Component::IRC::Common qw( :ALL );
        use POE::Component::IRC::Plugin qw( :ALL );        
    };


    Moose->init_meta(
        for_class  => $for,
        base_class => 'Adam::Plugin'
    );
}

sub events {
    my ( $caller, @events ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_events' => sub { return \@events } );
}

1;

__END__

=head1 NAME

Moses::Plugin - A class to ...

=head1 VERSION

This documentation refers to version 0.01.

=head1 SYNOPSIS

use Moses::Plugin;

=head1 DESCRIPTION

The Moses::Plugin class implements ...

=head1 SUBROUTINES / METHODS

=head2 init_meta

Parameters:
    none

Insert description of subroutine here...

=head2 events

Parameters:
    none

Insert description of subroutine here...

=head1 DEPENDENCIES

Modules used, version dependencies, core yes/no

Moose::Exporter

Adam::Plugin

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
