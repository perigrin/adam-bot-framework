package Adam::Plugin;
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

has events => (
    isa     => 'ArrayRef',
    traits  => ['Array'],
    builder => 'default_events',
    handles => { _events => 'elements' }
);

sub default_events {
    [ grep { s/(?:S|U)_(\w+)/$1/ } shift->meta->get_all_method_names ];
}

sub PCI_register {
    my ( $self, $irc ) = splice @_, 0, 2;
    $irc->plugin_register( $self, 'SERVER', $self->_events );
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

=head1 NAME

Adam::Plugin - A base class for Adam/Moses plugins

=head1 DESCRIPTION

The Adam::Plugin class implements a base class for Adam/Moses IRC bot plugins.

=head1 ATTRIBUTES

=head2 bot

=head2 events

=head1 METHODS

=head2 default_events

The default events that this plugin will listen to. It defaults to all methods
prefixed with 'S_' in the current class.


=head1 BUGS AND LIMITATIONS

None known currently, please email the author if you find any.

=head1 AUTHOR

Chris Prather (perigrin@domain.tld)

=head1 LICENCE

Copyright 2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
