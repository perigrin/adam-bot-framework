package Moses::Plugin;
# ABSTRACT: Sugar for Moses Plugins

use Moose       ();
use MooseX::POE ();
use Moose::Exporter;
use Adam::Plugin;

Moose::Exporter->setup_import_methods(
    with_caller => [qw(events)],
    also        => [qw(Moose)],
);

=head1 DESCRIPTION

The Moses::Plugin module provides a declarative sugar layer for
L<POE::Component::IRC> plugins based on the L<Adam::Plugin> class.

=cut

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

=func events

    events qw( S_public S_privmsg );

Declare which IRC events this plugin should listen to. Event names should be
prefixed with C<S_> for server events or C<U_> for user events.

=cut

1;
