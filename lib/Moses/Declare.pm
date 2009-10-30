use MooseX::Declare;

class Moses::Declare extends MooseX::Declare is dirty {
    use aliased 'Moses::Declare::Syntax::BotKeyword', 'BotKeyword';
    clean;
    around keywords( ClassName $self: )
      { $self->$orig, BotKeyword->new( identifier => 'bot' ), };
}

__END__
