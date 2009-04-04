package Adam::Compat::Bot::BasicBot::Pluggable;
use Moose::Role;
use Moose::Util::TypeConstraints;

requires qw(said help _build_store);

duck_type 'Adam::Bot::Store' => qw(get set unset var);

has store => (
    isa        => 'Adam::Bot::Store',
    is         => 'ro',
    lazy_build => 1,
    handles    => {
        get        => 'get',
        set        => 'set',
        var        => 'var',
        unset      => 'unset',
        store_keys => 'keys',
    }
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
sub stop      { }

before 'PCI_unregister' => sub { shift->stop() };

sub S_irc_connected { shift->connected(@_) }
sub S_join          { shift->chanjoin(@_) }
sub S_part          { shift->chanpart(@_) }
no Moose::Role;
1;
__END__
