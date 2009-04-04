package Adam::Bot::Store::Hash;
use Moose;
use MooseX::AttributeHelpers;

has store => (
    isa        => 'HashRef',
    is         => 'ro',
    lazy_build => 1,
    metaclass  => 'Collection::Hash',
    provides   => {
        get    => 'get',
        set    => 'set',
        delete => 'unset',
    }
);

sub var {
    my ( $self, $name, $value ) = @_;
    $self->set( $name => $value ) if $value;
    $self->get($name);
}

sub _build_store { {} }

no Moose;
1;
__END__
