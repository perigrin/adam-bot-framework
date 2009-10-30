use MooseX::Declare;

class Moses::Declare::Syntax::BotKeyword extends
  MooseX::Declare::Syntax::Keyword::Class {

    before add_namespace_customizations( Object $ctx, Str $package) {
        $ctx->add_preamble_code_parts( 'use Moses', );
      }

}

__END__
