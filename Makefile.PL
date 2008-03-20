# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'Pip';
all_from 'lib/Pip.pm';

# Specific dependencies
# requires 'Moose' => '0.25';

build_requires 'Test::More' => '0.42';

no_index 'directory' => 'ex';

auto_install;
WriteAll;
