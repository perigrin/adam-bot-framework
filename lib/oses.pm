package oses;
# ABSTRACT: A shortcut in the fashion of oose.pm
our $VERSION = '1.001';
use strict;
use warnings;

=head1 SYNOPSIS

    perl -Ilib -Moses=T -MNet::Twitter -e'event irc_public=>sub {
    Net::Twitter->new(username=>$ARGV[0],password=>$ARGV[1])->update($_[ARG2])
    };T->run'

=head1 DESCRIPTION

A source filter shortcut module in the fashion of C<oose.pm> that automatically
adds a package declaration and C<use Moses;> to your code.

=cut

BEGIN {
    my $package;
    sub import { $package = $_[1] || 'Bot' }
    use Filter::Simple sub { s/^/package $package;\nuse Moses;\n/; }
}

1;
