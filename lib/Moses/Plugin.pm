package Moses::Plugin;
# ABSTRACT: Sugar for Moses Plugins
# Dist::Zilla: +PodWeaver
use Moose       ();
use MooseX::POE ();
use Moose::Exporter;
use Adam::Plugin;

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

=head1 DESCRIPTION

The Moses::Plugin builds a declarative sugar layer for
L<POE::Component::IRC|POE::Component::IRC> plugins based on the
L<Adam::Plugin|Adam::Plugin> class.

=head1 FUNCTIONS

=head2 events (@events)

Insert description of subroutine here...

=head1 BUGS AND LIMITATIONS

None known currently, please report bugs to L<https://rt.cpan.org/Ticket/Create.html?Queue=Adam>

=cut
