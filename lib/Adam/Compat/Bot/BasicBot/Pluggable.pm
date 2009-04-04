package Adam::Compat::Bot::BasicBot::Pluggable;
use Moose::Role;
use Moose::Util::TypeConstraints;

requires qw(help _build_store);

duck_type 'Adam::Bot::Store' => qw(get set unset var);

has store => (
    isa        => 'Adam::Bot::Store',
    is         => 'ro',
    lazy_build => 1,
    handles    => {
        get        => 'get',
        set        => 'set',
        var        => 'var',
        unset      => 'unset',
        store_keys => 'keys',
    }
);

has bot => (
    isa => 'Adam',
    is  => 'ro',
);

#
# Public Methods
#
sub init { }
sub stop { }

sub connected { }
sub chanjoin  { }
sub chanpart  { }

sub say {

    # my $self = shift;
    # return $self->bot->say(@_);
}

sub reply {

    # my $self = shift;
    # return $self->bot->reply(@_);
}

sub tell {

    # my $self = shift;
    # my $target = shift;
    # my $body = shift;
    # if ($target =~ /^#/) {
    #   $self->say({ channel => $target, body => $body });
    # } else {
    #   $self->say({ channel => 'msg', body => $body, who => $target });
    # }
}

sub said {
    my ( $self, $mess, $pri ) = @_;
    $mess->{body} =~ s/(^\s*|\s*$)//g if defined $mess->{body};

    return $self->seen($mess)     if ( $pri == 0 );
    return $self->admin($mess)    if ( $pri == 1 );
    return $self->told($mess)     if ( $pri == 2 );
    return $self->fallback($mess) if ( $pri == 3 );
    return undef;
}

sub seen     { }
sub admin    { }
sub told     { }
sub fallback { }
sub emoted   { }
sub tick     { }

#
# Hookups
#

sub BUILD { shift->init() }

before 'PCI_unregister' => sub { shift->stop() };

sub S_irc_connected { shift->connected(@_) }
sub S_join          { shift->chanjoin(@_) }
sub S_part          { shift->chanpart(@_) }
no Moose::Role;
1;
__END__
