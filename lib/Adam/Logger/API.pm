package Adam::Logger::API;
# ABSTRACT: API Role for the Adam logger

use Moose::Role;
use namespace::autoclean;

=head1 DESCRIPTION

Defines the logging API interface required for Adam bot loggers.

=cut

requires qw(
  log
  debug
  info
  notice
  warning
  error
  critical
  alert
  emergency
);

1;
