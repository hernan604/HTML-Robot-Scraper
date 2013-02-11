package HTML::Robot::Scrapper::Encoding::Base;
use Moo;
use Data::Printer;
use Carp;

has robot => ( is => 'rw' );
has engine => ( is => 'rw' );

sub safe_encode {
    my ( $self, $headers, $content ) = @_;
    return $self->engine->safe_encode( $self->robot, $headers, $content );
}

1;

