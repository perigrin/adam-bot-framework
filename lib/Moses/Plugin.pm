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

Moses::Plugin - Sugar for Plugins

=head1 DESCRIPTION

The Moses::Plugin builds a declarative sugar layer for
L<POE::Component::IRC|POE::Component::IRC> plugins based on the
L<Adam::Plugin|Adam::Plugin> class.

=head1 FUNCTIONS

=head2 events (@events)

Insert description of subroutine here...

=head1 BUGS AND LIMITATIONS

None known currently, please email the author if you find any.

=head1 AUTHOR

Chris Prather (chris@prather.org)

=head1 LICENCE

Copyright 2007-2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
