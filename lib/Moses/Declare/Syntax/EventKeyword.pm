use MooseX::Declare;

class Moses::Declare::Syntax::EventKeyword extends
  MooseX::Declare::Syntax::Keyword::Method {

    sub register_method_declaration {
        my ( $self, $meta, $name, $method ) = @_;
        $meta->add_state_method( $name => $method );
    }
}

1;

__END__

