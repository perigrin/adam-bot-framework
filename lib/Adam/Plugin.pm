package Adam::Plugin;
# ABSTRACT: A base class for Adam/Moses plugins
# Dist::Zilla: +PodWeaver
use Moose;
use namespace::autoclean;

has bot => (
    isa      => 'Adam',
    is       => 'ro',
    required => 1,
    handles  => [
        qw(
          log
          owner
          irc
          yield
          privmsg
          nick
          )
    ],
);

has _events => (
    isa     => 'ArrayRef',
    is      => 'ro',
    traits  => ['Array'],
    builder => 'default_events',
    handles => { _list_events => 'elements' }
);

sub default_events {
    [ grep { s/([SU]_\w+)/$1/ } shift->meta->get_all_method_names ];
}

sub PCI_register {
    my ( $self, $irc ) = splice @_, 0, 2;
    my @events = $self->_list_events;
    my @s_events = map { s/^S_//; $_ } grep { /^S_/ } @events;
    my @u_events = map { s/^U_//; $_ } grep { /^U_/ } @events;
    $irc->plugin_register($self, 'SERVER', @s_events) if @s_events;
    $irc->plugin_register($self, 'USER', @u_events) if @u_events;
    return 1;
}

sub PCI_unregister {
    my ( $self, $irc ) = @_;
    return 1;
}

sub _default {
    my ( $self, $irc, $event ) = @_;
    $self->log->notice("_default called for $event");
}

1;

__END__

=head1 DESCRIPTION

The Adam::Plugin class implements a base class for Adam/Moses IRC bot plugins.

=head1 ATTRIBUTES

=head2 bot

=head1 METHODS

=head2 default_events

The default events that this plugin will listen to. It defaults to all methods
prefixed with 'S_' or 'U_' in the current class.

=head1 BUGS AND LIMITATIONS

None known currently, please report bugs to L<https://rt.cpan.org/Ticket/Create.html?Queue=Adam>

=cut
