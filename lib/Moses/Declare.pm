use MooseX::Declare;

class Moses::Declare extends MooseX::Declare {
    use aliased 'Moses::Declare::Syntax::BotKeyword';
    around keywords( ClassName $self: )
      { $self->$orig, BotKeyword->new( identifier => 'bot' ), };
}

__END__
