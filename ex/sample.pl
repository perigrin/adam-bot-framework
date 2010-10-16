package SampleBot;
use Moses;

server 'irc.perl.org';
nickname 'sample-bot';
channels '#reflex';

has message => (
    isa     => 'Str',
    is      => 'rw',
    default => 'I use Reflex!',
);

sub on_poco_irc_bot_addressed {
    my ( $self, $args ) = @_;
    my ( $nickstr, $channel, $msg ) = @$args{ 0, 1, 2 };
    my ($nick) = split /!/, $nickstr;
    $self->privmsg( $channel => "$nick: ${ \$self->message }" );
}

__PACKAGE__->run unless caller;

no Moses;
1;
__END__
