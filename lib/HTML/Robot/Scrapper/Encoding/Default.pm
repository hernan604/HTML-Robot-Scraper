package HTML::Robot::Scrapper::Encoding::Default;
use Encode::Guess qw/iso-8859-1 utf8/;
use Moo;
use Encode;
use utf8;
use Data::Printer;

sub safe_encode {
    my ( $self, $robot, $headers, $content ) = @_;
    Encode::Guess->add_suspects(qw/iso-8859-1 utf8/);
    my $decoder = Encode::Guess->guess($content);
    return decode_utf8($content) unless ref($decoder);
    my $content_utf8 = $decoder->decode($content);
    return $content_utf8;
}

1;

