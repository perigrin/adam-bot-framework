package Adam::Bot::Store;
use Moose::Role;

requires qw(get set keys var unset);

no Moose::Role;
1;
__END__
