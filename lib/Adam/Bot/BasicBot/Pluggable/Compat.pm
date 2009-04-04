package Adam::Bot::BasicBot::Pluggable::Compat;
use Moose::Role;
use Moose::Util::TypeConstraints;

requires qw(said help _build_store);

duck_type 'Adam::Bot::Store' => qw(get set unset var);

has store => (
    isa        => 'Adam::Bot::Store',
    is         => 'ro',
    lazy_build => 1,
    handles    => [qw(get set var unset)]
);

has bot => (
    isa => 'Adam',
    is  => 'ro',
);

sub BUILD { shift->init() }

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
