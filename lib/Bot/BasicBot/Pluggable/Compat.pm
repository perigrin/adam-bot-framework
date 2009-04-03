package Bot::BasicBot::Pluggable::Compat;
use Moose::Role;
use MooseX::AttributeHelpers;

requires qw(said help);

has store => (
    isa       => 'HashRef',
    is        => 'ro',
    default   => sub { {} },
    metaclass => 'Collection::Hash',
    provides  => {
        get    => 'get',
        set    => 'set',
        delete => 'unset',
    }
);

sub seen     { }
sub admin    { }
sub told     { }
sub fallback { }
sub chanjoin { }
sub chanpart { }
sub tick     { }

no Moose::Role;
1;
__END__
