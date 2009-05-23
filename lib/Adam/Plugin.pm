package Adam::Plugin;
use Moose;

# use POE::Component::IRC::Plugin qw( :ALL );

has irc => (
    isa     => 'Object',
    is      => 'rw',
    clearer => 'clear_irc',
    handles => [qw(log)]
);

has events => (
    isa        => 'ArrayRef',
    is         => 'ro',
    auto_deref => 1,
    lazy_build => 1,
    builder    => 'default_events',
);

sub default_events { [qw(public)] }

# 
# sub privmsg {
#     my $self = shift;
#     $self->irc->yield( privmsg => @_ );
# }
# 

sub PCI_register {
     my ($self, $irc) = splice @_, 0, 2;
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
