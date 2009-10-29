package Adam::Logger::Default;
use Moose;

with qw(
  Adam::Logger::API
  MooseX::LogDispatch::Levels
);

1;
__END__
