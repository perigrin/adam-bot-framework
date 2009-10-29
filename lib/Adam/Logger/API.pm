package Adam::Logging::API;
use Moose::Role;
use namespace::autoclean;

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
__END__
