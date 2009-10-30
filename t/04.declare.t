#!/usr/bin/env perl
use Test::More;
use Moses::Declare;

bot SampleBot {
    server 'irc.perl.org';
    channels '#bots';

    has message => (
        isa     => 'Str',
        is      => 'rw',
        default => 'Hello',
    );

    on irc_bot_addressed {
        my ( $self, $nickstr, $channel, $msg ) = @_[ OBJECT, ARG0, ARG1, ARG2 ];
        my ($nick) = split /!/, $nickstr;
        $self->privmsg( $channel => "$nick: ${ \$self->message }" );
    };
}

ok( my $bot = SampleBot->new(), 'new bot' );
is( $bot->get_server,   'irc.perl.org',     'right server' );
is( $bot->get_nickname, 'SampleBot',        'right nick' );
is( $bot->nick,         $bot->get_nickname, 'nick alias works' );
is_deeply( scalar $bot->get_channels, ['#bots'], 'right channels' );
done_testing;
