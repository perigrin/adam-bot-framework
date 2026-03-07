package Adam::Logger::Default;
# ABSTRACT: Default logger for Adam bots
our $VERSION = '1.001';
use Moose;
use POSIX qw( strftime );

=head1 DESCRIPTION

Default logging implementation for Adam bots using L<MooseX::LogDispatch::Levels>.
Log messages include timestamps in C<[YYYY-MM-DD HH:MM:SS]> format.

=cut

with qw(
  Adam::Logger::API
  MooseX::LogDispatch::Levels
);

around log => sub {
  my ($orig, $self, %args) = @_;
  my $ts = strftime('%Y-%m-%d %H:%M:%S', localtime);
  $args{message} = "[$ts] [$args{level}] $args{message}";
  $self->$orig(%args);
};

1;
