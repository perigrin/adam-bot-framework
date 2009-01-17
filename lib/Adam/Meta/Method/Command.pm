package Adam::Meta::Method::Command;
use Moose;
use Moose::Util::TypeConstraints;

subtype 'Adam::CommandString' => as 'RegexpRef';
coerce 'Adam::CommandString' => from 'Str' => via { qr/\Q$_\E/ };

has trigger => (
    isa      => 'Adam::CommandString',
    is       => 'ro',
    required => 1,
);

no Moose;
1;
