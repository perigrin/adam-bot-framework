package oses;
use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:PERIGRIN';

BEGIN {
    my $package;
    sub import { $package = $_[1] || 'Class' }
    use Filter::Simple sub { s/^/package $package;\nuse Moses;\n/; }
}

1;
__END__
