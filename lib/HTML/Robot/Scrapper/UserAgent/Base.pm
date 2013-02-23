package  HTML::Robot::Scrapper::UserAgent::Base;
use Moo;

has robot => ( is => 'rw', );
has engine => ( is => 'rw', );

sub normalize_url {
    my ( $self, $url ) = @_;
    return $self->engine->normalize_url( $self->robot, $url );
}

sub visit {
    my ( $self, $item ) = @_;
    return $self->engine->visit( $self->robot , $item );
};


sub headers {
    my ( $self, $headers ) = @_;
    return $self->engine->_headers( $self->robot, $headers );
}

sub content {
    my ( $self, $content ) = @_;
    return $self->engine->_content( $self->robot, $content );
}

sub content_type {
    my ( $self, $content_type ) = @_;
    return $self->engine->_content_type( $self->robot, $content_type );
}

sub charset {
    my ( $self, $charset ) = @_;
    return $self->engine->_charset( $self->robot, $charset );
}

sub current_page { #TODO> totrar para current_url ou url
    my ( $self, $url ) = @_;
    return $self->engine->_current_page( $self->robot, $url );
}

1;
