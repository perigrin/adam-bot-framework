package Adam::Bot::Store::Hash;
use Moose;
use MooseX::AttributeHelpers;

has data => (
    isa        => 'HashRef',
    is         => 'ro',
    lazy_build => 1,
    metaclass  => 'Collection::Hash',
    provides   => {
        get    => 'get',
        set    => 'set',
        delete => 'unset',
        keys   => 'keys',
    }
);

sub var {
    my ( $self, $name, $value ) = @_;
    $self->set( $name => $value ) if $value;
    $self->get($name);
}

sub _build_data { {} }


with qw(Adam::Bot::Store);

no Moose;
1;
__END__
