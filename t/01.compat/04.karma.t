#!/usr/bin/perl
$|++;
use warnings;
use strict;

use Test::More tests => 33;
use FindBin qw($Bin);
use lib "$Bin/lib";

use Karma;
{

    package TestBot;
    use Moses;
    nickname('karmabot');
    no Moses;
}

my $karma = Karma->new( bot => TestBot->new );

$karma->set( "user_num_comments", 0 );

is( say('karma alice'), 'alice has karma of 0.', 'inital karma of alice' );
is(
    say('explain karma alice'),
    'positive: 0; negative: 0; overall: 0.',
    'explain initial karma of alice'
);

say('alice--');
is(
    say('karma alice'),
    'alice has karma of -1.',
    'karma of alice after first --'
);

say('alice++');
say('alice++');
is(
    say('karma alice'),
    'alice has karma of 1.',
    'karma of alice after first ++'
);

say('alice++');
is(
    say('karma alice'),
    'alice has karma of 2.',
    'karma of alice after second ++'
);

is(
    say('explain karma alice'),
    'positive: 3; negative: 1; overall: 2.',
    'explain karma of Alice'
);

is( say('karmabot++'), 'Thanks!', 'thanking for karming up bot' );
is( say( 'karmabot--', 'alice' ),
    'Pbbbbtt!', 'complaining about karming down bot' );

is( say('++'), 'Thanks!', 'thanking up bot without explicit addressing' );
is( say('--'), 'Pbbbbtt!',
    'complaining about karming down bot without explicit addressing' );

say('bob++');
test_karma( 'bob', 0, 'user is not allowed to use positiv selfkarma' );

say('bob--');
test_karma( 'bob', 0, 'user is not allowed to use negative selfkarma' );

$karma->set( 'user_ignore_selfkarma', 0 );

say('bob++');
test_karma( 'bob', 1, 'user is allowed to use positive selfkarma' );

say('bob--');
test_karma( 'bob', 0, 'user is allowed to use negativ selfkarma' );

say('Foo alice--');
is( say('karma alice'), 'alice has karma of 1.', 'negative karma in sentance' );

say('Foo alice++');
is( say('karma alice'), 'alice has karma of 2.', 'positiv karma in sentance' );

is(
    $karma->help(),
'Gives karma for or against a particular thing. Usage: <thing>++ # comment, <thing>-- # comment, karma <thing>, explain <thing>.',
    'help for karma'
);

is(
    say('karma'),
    'bob has karma of 0.',
    'asking for own karma without arguments'
);

is( say( 'foobar', 'alice' ), '', 'ignoring karma unrelated issues' );

say('(alice code)--');
is(
    say('karma alice code'),
    'alice code has karma of -1.',
    'decrease karma of things with spaces '
);

say('(alice code)++');
is(
    say('karma alice code'),
    'alice code has karma of 0.',
    'increasing karma of things with spaces '
);

say('alice: ++');
is( say('karma alice'), 'alice has karma of 2.', 'positiv karma in sentance' );

is( say( 'explain', '' ), '', 'ignore explain without argument' );

is( indirect('++'), '', 'ignoring ++ without thing or address' );
is( indirect('--'), '', 'ignoring -- without thing or address' );

## Now we start testing reasons
$karma->set( "user_num_comments",      2 );
$karma->set( "user_show_givers",       0 );
$karma->set( "user_randomize_reasons", 0 );

say('alice++ good cipher');
is(
    say('explain alice'),
    'positive: good cipher; negative: nothing; overall: 3.',
    'explaining karma of alice with one positive reason'
);

say('alice-- bad cipher');
is(
    say('explain alice'),
    'positive: good cipher; negative: bad cipher; overall: 2.',
    'explaining karma of alice with one positive and negative reason'
);

say('alice-- Friend of Eve');
is(
    say('explain alice'),
    'positive: good cipher; negative: Friend of Eve, bad cipher; overall: 1.',
    'explaining karma of alice with one positive and two negative reason'
);

say('alice-- Friend of Mallory');
is(
    say('explain alice'),
'positive: good cipher; negative: Friend of Mallory, Friend of Eve; overall: 0.',
'explaining karma of alice with more than two reasons (user_num_commments=2)'
);

$karma->set( "user_show_givers", 1 );

is(
    say('explain alice'),
'positive: good cipher (bob); negative: Friend of Mallory (bob), Friend of Eve (bob); overall: 0.',
    'explaining karma of alice with reasons and givers'
);

$karma->set( "user_randomize_reasons", 1 );

{
    my %explanations;
    for ( 1 .. 100 ) {
        $explanations{ say('explain alice') }++;
    }
    is( keys %explanations, 6, 'Testing randomness of reason list... (uh!)' )
}

sub test_karma {
    my ( $thing, $value, $message ) = @_;
    is( $karma->get_karma($thing), $value, $message );
}

sub indirect {
    my ($body) = @_;
    my $mess = { who => 'bob', body => $body || '' };
    ## The return code of seen is ignored
    $karma->seen($mess);
    return $karma->told($mess) || '';
}

sub say {
    my ( $body, $to ) = @_;
    my $mess =
      { who => 'bob', body => $body || '', address => $to || 'karmabot' };
    ## return code of seen is ignored
    $karma->seen($mess);
    return $karma->told($mess) || '';
}
