package Adam::Plugin;
# ABSTRACT: A base class for Adam/Moses plugins
our $VERSION = '1.003';
use Moose;
use namespace::autoclean;

=head1 DESCRIPTION

The Adam::Plugin class implements a base class for Adam/Moses IRC bot plugins.

=cut

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

=attr bot

The L<Adam> bot instance. Required. Handles several methods from the bot
including C<log>, C<owner>, C<irc>, C<yield>, C<privmsg>, and C<nick>.

=cut

has _events => (
    isa     => 'ArrayRef',
    is      => 'ro',
    traits  => ['Array'],
    builder => 'default_events',
    handles => { _list_events => 'elements' }
);

sub default_events {
    [ grep { /^[SU]_\w+/ } shift->meta->get_all_method_names ];
}

=method default_events

The default events that this plugin will listen to. Returns an ArrayRef of all
methods prefixed with C<S_> (server events) or C<U_> (user events) in the current
class.

=cut

sub PCI_register {
    my ( $self, $irc ) = splice @_, 0, 2;
    my @events = $self->_list_events;
    my @s_events = map { s/^S_//; $_ } grep { /^S_/ } @events;
    my @u_events = map { s/^U_//; $_ } grep { /^U_/ } @events;
    $irc->plugin_register($self, 'SERVER', @s_events) if @s_events;
    $irc->plugin_register($self, 'USER', @u_events) if @u_events;
    return 1;
}

=method PCI_register

Called when the plugin is registered with the IRC component. Automatically
registers server and user events based on method names.

=cut

sub PCI_unregister {
    my ( $self, $irc ) = @_;
    return 1;
}

=method PCI_unregister

Called when the plugin is unregistered from the IRC component.

=cut

sub _default {
    my ( $self, $irc, $event ) = @_;
    $self->log->notice("_default called for $event");
}

1;
