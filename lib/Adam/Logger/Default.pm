package Adam::Logger::Default;
# ABSTRACT: Default logger for Adam bots

use Moose;

=head1 DESCRIPTION

Default logging implementation for Adam bots using L<MooseX::LogDispatch::Levels>.

=cut

with qw(
  Adam::Logger::API
  MooseX::LogDispatch::Levels
);

1;
