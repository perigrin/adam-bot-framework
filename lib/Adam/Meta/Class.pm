package Adam::Meta::Class;
use Moose;

extends qw(Moose::Meta::Class);

with qw(Adam::Meta::Trait);

around add_method => sub {
    my ( $next, $self, @params ) = @_;

    $self->$next(@params);
};

no Moose;
1;
__END__
