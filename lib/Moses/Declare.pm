use MooseX::Declare;

class Moses::Declare extends MooseX::Declare {
    use aliased 'Moses::Declare::Syntax::BotKeyword';
    use aliased 'Moses::Declare::Syntax::PluginKeyword';
    around keywords( ClassName $self: ) {
        $self->$orig,
        BotKeyword->new( identifier => 'bot' ),
        PluginKeyword->new( identifier => 'plugin' ),
    };
}

__END__
