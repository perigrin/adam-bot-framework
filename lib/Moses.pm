package Moses;
our $VERSION = 0.080;
use Moose;
use MooseX::POE::Meta::Class;
use Adam;
use Sub::Name 'subname';
use Sub::Exporter;
use B qw(svref_2object);
{
    my $CALLER;
    my %exports = (
        event => sub {
            my $class = $CALLER;
            return subname 'MooseX::POE::event' => sub ($&) {
                my ( $name, $method ) = @_;
                $class->meta->add_state_method( $name => $method );
            };
        },
        nickname => sub {
            my $class = $CALLER;
            return subname 'Moses::nickname' => sub ($) {
                my ($name) = @_;
                $class->meta->add_method(
                    'default_nickname' => sub { return $name } );
              }
        },
        server => sub {
            my $class = $CALLER;
            return subname 'Moses::server_name' => sub ($) {
                my ($name) = @_;
                $class->meta->add_method(
                    'default_server' => sub { return $name } );
              }
        },
        port => sub {
            my $class = $CALLER;
            return subname 'Moses::port' => sub ($) {
                my ($port) = @_;
                $class->meta->add_method( 'default_port' => sub { return $port }
                );
              }
        },
        channels => sub {
            my $class = $CALLER;
            return subname 'Moses::channels' => sub (@) {
                my @channels = @_;
                $class->meta->add_method(
                    'default_channels' => sub { return \@channels } );
              }
        },
        plugins => sub {
            my $class = $CALLER;
            return subname 'Moses::plugins' => sub (@) {
                my %plugins = @_;
                $class->meta->add_method(
                    'custom_plugins' => sub { return \%plugins } );
              }
        },

    );

    my $exporter = Sub::Exporter::build_exporter(
        {
            exports => \%exports,
            groups  => { default => [':all'] }
        }
    );

    sub import {
        my ( $pkg, $subclass ) = @_;
        $CALLER = caller();
        strict->import;
        warnings->import;

        return if $CALLER eq 'main';
        my $object_class = 'Adam';
        my $meta_class   = 'MooseX::POE::Meta::Class';

        if ($subclass) {
            $object_class .= '::' . ucfirst $subclass;
        }

        Moose::init_meta( $CALLER, $object_class, $meta_class );
        Moose->import( { into => $CALLER } );
        ## no critic
        eval qq{package $CALLER; use POE; };
        ## use critic
        die $@ if $@;

        goto $exporter;
    }

    sub unimport {
        no strict 'refs';
        my $class = caller();

        # loop through the exports ...
        foreach my $name ( keys %exports ) {

            # if we find one ...
            if ( defined &{ $class . '::' . $name } ) {
                my $keyword = \&{ $class . '::' . $name };

                # make sure it is from Moose
                my $pkg_name =
                  eval { svref_2object($keyword)->GV->STASH->NAME };
                next if $@;

                if ( $pkg_name eq 'MooseX::POE' || $pkg_name eq 'Moses' ) {
                    delete ${ $class . '::' }{$name};
                }
            }
        }

        # now let Moose do the same thing
        goto &{ Moose->can('unimport') };
    }
}
no Moose;
1;
__END__
