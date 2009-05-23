package Moses::Plugin;
use Moose       ();
use MooseX::POE ();
use Moose::Exporter;
use Adam::Plugin;

our $VERSION = $Adam::VERSION;

Moose::Exporter->setup_import_methods(
    also        => [qw(MooseX::POE)],
);

sub init_meta {
    my ( $class, %args ) = @_;

    my $for = $args{for_class};
    eval qq{package $for; use POE; };

    Moose->init_meta(
        for_class  => $for,
        base_class => 'Adam::Plugin'
    );
}