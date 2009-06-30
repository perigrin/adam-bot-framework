# Load the Module::Install bundled in ./inc/
use inc::Module::Install;
include     'Module::AutoInstall';

# Define metadata
name 'Adam';
all_from 'lib/Adam.pm';

# Specific dependencies
requires 'MooseX::POE'          => '0.09';
requires 'POE::Component::IRC'  => undef;
requires 'MooseX::Getopt'       => undef;
requires 'MooseX::SimpleConfig' => undef;
requires 'MooseX::LogDispatch'  => undef;

build_requires 'Test::More' => '0.42';

no_index 'directory' => 'ex';

auto_set_repository;
auto_manifest;
auto_install;
WriteAll;
