use MooseX::Declare;

class Moses::Declare::Syntax::BotKeyword extends
  MooseX::Declare::Syntax::Keyword::Class {

    use aliased 'Moses::Declare::Syntax::EventKeyword';

    before add_namespace_customizations( Object $ctx, Str $package) {
        $ctx->add_preamble_code_parts( 'use Moses', );
    };
    use Moose::Util::TypeConstraints;

    class_type 'POE::Session';
    class_type 'POE::Kernel';
    around default_inner {
        my $val = $self->$orig(@_);
        push @$val,
          (
            EventKeyword->new(
                identifier           => 'on',
                modifier_type        => 'on',
            ),
          );
        return $val;
    };

}

__END__
