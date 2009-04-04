#!/usr/bin/env perl
use warnings;
use strict;

use Test::More tests => 13;
use Adam::Bot::Store::Hash;
my $store;
{

    package TestPlugin;
    use Moose;
    extends qw(Adam::Plugin);
    with qw(Adam::Bot::BasicBot::Pluggable::Compat);

    sub _build_store { $store ||= Adam::Bot::Store::Hash->new() }
    sub help         { 'test' }
    sub said         { }

    no Moose
}

;

ok( my $base = TestPlugin->new(), "created base module" );
ok( $base->var( 'test', 'value' ), "set variable" );
ok( $base->var('test') eq 'value', 'got variable' );

ok( $base = TestPlugin->new(), "created new base module" );
ok( $base->var('test') eq 'value', 'got old variable' );

ok( $base->unset('test'),           'unset variable' );
ok( !defined( $base->var('test') ), "it's gone" );

# very hard to do anything but check existence of these methods
ok( $base->can($_), "'$_' exists" ) for (qw(said connected tick emoted init));

ok( $base->help, "help returns something" );
