package HTML::Robot::Scrapper::Encoding::Base;
use Moose;
use Data::Printer;
use Carp;

has robot => ( is => 'rw' );
has engine => ( is => 'rw' );

sub safe_encode {
    my ( $self, $headers, $content ) = @_;
    #headers is here in case we decide its better to
    #use charset from headers for encoding
    return $self->engine->safe_encode( $self->robot, $headers, $content );
}

1;

