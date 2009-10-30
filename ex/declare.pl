use lib qw(lib);
use Moses::Declare;

bot MasterMold {
    server 'irc.perl.org';
    channels '#moses';

    has message => (
        isa     => 'Str',
        is      => 'rw',
        default => 'Mutant Detected!',
    );

    on irc_bot_addressed {
        my ( $nickstr, $channel, $msg ) = @_[ ARG0, ARG1, ARG2 ];
        my ($nick) = split /!/, $nickstr;
        $self->privmsg( $channel => "$nick: ${ \$self->message }" );
    }
}

my @bots = map { MasterMold->new( nickname => "Sentinel_${_}" ) } ( 1 .. 2 );

POE::Kernel->run;
