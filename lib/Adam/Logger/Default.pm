package Adam::Logger::Default;
# ABSTRACT: Default logger for Adam bots
use Moose;

with qw(
  Adam::Logger::API
  MooseX::LogDispatch::Levels
);

1;
__END__
