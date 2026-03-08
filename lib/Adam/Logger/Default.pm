package Adam::Logger::Default;
# ABSTRACT: Default logger for Adam bots
our $VERSION = '1.002';
use Moose;
use POSIX qw( strftime );

=head1 DESCRIPTION

Default logging implementation for Adam bots using L<MooseX::LogDispatch::Levels>.
Log messages include timestamps in C<[YYYY-MM-DD HH:MM:SS]> format.

=cut

sub log_dispatch_conf {
  return {
    class     => 'Log::Dispatch::Screen',
    min_level => 'debug',
    stderr    => 1,
    callbacks => sub {
      my %p = @_;
      my $ts = strftime('%Y-%m-%d %H:%M:%S', localtime);
      return "[$ts] [$p{level}] $p{message}\n";
    },
  };
}

with qw(
  Adam::Logger::API
  MooseX::LogDispatch::Levels
);

1;
