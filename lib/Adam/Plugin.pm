package Adam::Plugin;
use Moose;

use POE::Component::IRC::Plugin qw(PCI_EAT_ALL PCI_EAT_NONE);

has irc => (
    isa     => 'Object',
    is      => 'rw',
    clearer => 'clear_irc',
);

has events => (
    isa        => 'ArrayRef',
    is         => 'ro',
    auto_deref => 1,
    lazy       => 1,
    default    => sub { [qw(msg bot_addressed public)] },
);

sub privmsg {
    my $self = shift;
    $self->irc->yield( privmsg => @_ );
}

sub PCI_register {
    my ( $self, $irc ) = @_;
    $self->irc($irc);
    $irc->plugin_register( $self, 'SERVER', $self->events );
    return 1;
}

sub PCI_unregister {
    my ( $self, $irc ) = @_;
    $self->clear_irc;
    return 1;
}

no Moose;
1;
