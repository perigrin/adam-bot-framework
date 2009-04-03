package Moses;
our $VERSION = 0.090;
use Moose       ();
use MooseX::POE ();
use Moose::Exporter;
use Adam;

my ( $import, $unimport ) = Moose::Exporter->build_import_methods(
    with_caller => [qw(nickname server port channels plugins)],
    also        => [qw(MooseX::POE)],
);

*unimport = $unimport;

sub import {
    my ( $traits, @args ) = Moose::Exporter::_strip_traits(@_);
    $CALLER = Moose::Exporter::_get_caller(@args);
    eval qq{package $CALLER; use POE; };
    goto &$import;
}

sub init_meta {
    my ( $class, %args ) = @_;

    my $for = $args{for_class};

    Moose->init_meta(
        for_class  => $for,
        base_class => 'Adam'
    );    
}

sub nickname ($) {
    my ( $caller, $name ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_nickname' => sub { return $name } );
}

sub server ($) {
    my ( $caller, $name ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_server' => sub { return $name } );
}

sub port ($) {
    my ( $caller, $port ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_port' => sub { return $port } );
}

sub channels (@) {
    my ( $caller, @channels ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'default_channels' => sub { return \@channels } );
}

sub plugins (@) {
    my ( $caller, %plugins ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_method( 'custom_plugins' => sub { return \%plugins } );
}

1;
__END__
