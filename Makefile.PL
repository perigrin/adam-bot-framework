# Load the Module::Install bundled in ./inc/
use inc::Module::Install;
include 'Module::AutoInstall';

# Define metadata
name 'Adam';
all_from 'lib/Adam.pm';

# Specific dependencies
requires 'MooseX::POE'          => '0.09';
requires 'namespace::autoclean' => '0.09';
requires 'MooseX::Aliases'      => '0.05';
requires 'POE::Component::IRC'  => '6.12';
requires 'MooseX::Getopt'       => '0.22';
requires 'MooseX::SimpleConfig' => '0.03';
requires 'MooseX::LogDispatch'  => '1.200';
requires 'MooseX::Declare'      => '0.31';

build_requires 'Test::More' => '0.94';
build_requires 'Test::Deep' => '0.103';

no_index 'directory' => 'ex';

auto_set_repository;
auto_manifest;
WriteAll;
