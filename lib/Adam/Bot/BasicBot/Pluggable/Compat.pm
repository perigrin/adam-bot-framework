package Adam::Bot::BasicBot::Pluggable::Compat;
use Moose::Role;
use Moose::Util::TypeConstraints;

requires qw(said help);

duck_type 'Adam::Bot::Store' => qw(get set unset var);

has store => (
    isa        => 'Adam::Bot::Store',
    is         => 'ro',
    lazy_build => 1,
    handles => [qw(get set var unset)]
);

sub _build_store {
    Adam::Bot::Store::Hash->new();
}

sub init      { }
sub emoted    { }
sub connected { }
sub seen      { }
sub admin     { }
sub told      { }
sub fallback  { }
sub chanjoin  { }
sub chanpart  { }
sub tick      { }

no Moose::Role;
1;
__END__
