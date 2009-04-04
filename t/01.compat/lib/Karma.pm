package Karma;
use Moose;
extends qw(Adam::Plugin);
with qw(Adam::Compat::Bot::BasicBot::Pluggable);

use Adam::Bot::Store::Hash;

sub _build_store {
    Adam::Bot::Store::Hash->new();
}

sub said { }

sub init {
    my $self = shift;
    $self->set( "user_ignore_selfkarma", 1 )
      unless defined( $self->get("user_ignore_selfkarma") );
    $self->set( "user_num_comments", 3 )
      unless defined( $self->get("user_num_comments") );
    $self->set( "user_show_givers", 1 )
      unless defined( $self->get("user_show_givers") );
    $self->set( "user_randomize_reasons", 1 )
      unless defined( $self->get("user_randomize_reasons") );
}

sub help {
    return
"Gives karma for or against a particular thing. Usage: <thing>++ # comment, <thing>-- # comment, karma <thing>, explain <thing>.";
}

sub seen {
    my ( $self, $mess ) = @_;
    my $body = $mess->{body};
    return 0 unless defined $body;
    my ( $command, $param ) = split( /\s+/, $body, 2 );
    $command = lc($command);
    if (   ( $body =~ /(\w+)\+\+\s*#?\s*/ )
        or ( $body =~ /\(([\w\s]+)\)\+\+\s*#?\s*/ ) )
    {
        return
          if ( ( $1 eq $mess->{who} ) and $self->get("user_ignore_selfkarma") );
        return $self->add_karma( $1, 1, $', $mess->{who} );
    }
    elsif (( $body =~ /(\w+)\-\-\s*#?\s*/ )
        or ( $body =~ /\(([\w\s]+)\)\-\-\s*#?\s*/ ) )
    {
        return
          if ( ( $1 eq $mess->{who} ) and $self->get("user_ignore_selfkarma") );
        return $self->add_karma( $1, 0, $', $mess->{who} );
    }
    elsif ( $mess->{address} && ( $body =~ /\+\+\s*#?\s*/ ) ) {
        return $self->add_karma( $mess->{address}, 1, $', $mess->{who} );

    # our body check here is constrained to the beginning of the line with
    # an optional "-" of "--" because Bot::BasicBot sees "<botname>-" as being
    # an addressing mode (along with "," and ":"). so, "<botname>--" comes
    # through as "<botname>-" in {address} and "-" as the start of our body.
    # TODO: add some sort of $mess->{rawbody} to Bot::BasicBot.pm. /me grumbles.
    }
    elsif ( $mess->{address} && ( $body =~ /\-?\-\s*#?\s*/ ) ) {
        return $self->add_karma( $mess->{address}, 0, $', $mess->{who} );
    }
}

sub told {
    my ( $self, $mess ) = @_;
    my $body = $mess->{body};

    my ( $command, $param ) = split( /\s+/, $body, 2 );
    $command = lc($command);

    my $nick = $self->bot->nick;

    my $tmp = $command;
    if ( $tmp =~ s!^$nick!! or $nick = $mess->{address} ) {
        if ( $tmp eq '++' ) {
            return "Thanks!";
        }
        elsif ( $tmp =~ /^--?$/ ) {
            return "Pbbbbtt!";
        }
    }

    if ( $command eq "karma" ) {
        if ($param) {
            return "$param has karma of " . $self->get_karma($param) . ".";
        }
        else {
            return
                $mess->{who}
              . " has karma of "
              . $self->get_karma( $mess->{who} ) . ".";
        }
    }
    elsif ( $command eq "explain" and $param ) {
        $param =~ s/^karma\s+//i;
        my ( $karma, $good, $bad ) = $self->get_karma($param);
        my $reply = "positive: " . $self->format_reasons($good) . "; ";
        $reply .= "negative: " . $self->format_reasons($bad) . "; ";
        $reply .= "overall: $karma.";

        return $reply;
    }
}

sub format_reasons {
    my ( $self, $reason ) = @_;
    my $num_comments = $self->get('user_num_comments');

    if ( $num_comments == 0 ) {
        return scalar( $reason->() );
    }

    my @reasons     = $reason->();
    my $num_reasons = @reasons;

    if ( $num_reasons == 0 ) {
        return 'nothing';
    }

    if ( $num_reasons == 1 ) {
        return ( $self->maybe_add_giver(@reasons) )[0];
    }

    $self->trim_list( \@reasons, $num_comments );
    return join( ', ', $self->maybe_add_giver(@reasons) );
}

sub maybe_add_giver {
    my ( $self, @reasons ) = @_;
    if ( $self->get('user_show_givers') ) {

        # adding a (user) string to the all reasons
        return map { $_->{reason} . ' (' . $_->{who} . ')' } @reasons;
    }
    else {

        # just returning the reason string of the reason hash referenes
        return map { $_->{reason} } @reasons;
    }
}

sub get_karma {
    my ( $self, $object ) = @_;
    $object = lc($object);
    $object =~ s/-/ /g;

    my @changes = @{ $self->get("karma_$object") || [] };

    my ( @good, @bad );
    my $karma    = 0;
    my $positive = 0;
    my $negative = 0;

    for my $row (@changes) {

        # just push non empty reasons on the array
        my $reason = $row->{reason};
        if ( $row->{positive} ) { $positive++; push( @good, $row ) if $reason }
        else                    { $negative++; push( @bad, $row ) if $reason }
    }
    $karma = $positive - $negative;

    # The subroutine references return differant values when called.
    # If they are called in scalar context, they return the overall
    # positive or negative karma, but when called in list context you
    # get an array of hash references with all non empty reasons back.

    return wantarray()
      ? (
        $karma,
        sub { return wantarray ? @good : $positive },
        sub { return wantarray ? @bad  : $negative }
      )
      : $karma;
}

sub add_karma {
    my ( $self, $object, $good, $reason, $who ) = @_;
    $object = lc($object);
    $object =~ s/-/ /g;
    my $row =
      { reason => $reason, who => $who, timestamp => time, positive => $good };
    my @changes = @{ $self->get("karma_$object") || [] };
    push @changes, $row;
    $self->set( "karma_$object" => \@changes );
    return 1;
}

sub trim_list {
    my ( $self, $list, $count ) = @_;

    # If radomization isn't requested we just return the reasons
    # in reversed cronological order

    if ( $self->get('user_randomize_reasons') ) {
        fisher_yates_shuffle($list);
    }
    else {
        @$list = reverse sort { $b->{timestamp} cmp $a->{timestamp} } @$list;
    }

    if ( scalar(@$list) > $count ) {
        @$list = splice( @$list, 0, $count );
    }
}

sub fisher_yates_shuffle {
    my $array = shift;
    my $i     = @$array;
    while ( $i-- ) {
        my $j = int rand( $i + 1 );
        @$array[ $i, $j ] = @$array[ $j, $i ];
    }
}

1;
