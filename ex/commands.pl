package SampleBot;
use Moses;

server 'irc.perl.org';
nickname 'echo-bot';
channels '#bots';

command 'echo' => sub { 
    my ( $self, $trigger, $ctxt) = @_;
    
};

event irc_bot_addressed => sub {
    my ( $self, $nickstr, $channel, $msg ) = @_[ OBJECT, ARG0, ARG1, ARG2 ];
    my ($nick) = split /!/, $nickstr;
    $self->privmsg( $channel => "$nick: ${ \$self->message }" );
};

__PACKAGE__->run unless caller;

no Moses;
1;
__END__
