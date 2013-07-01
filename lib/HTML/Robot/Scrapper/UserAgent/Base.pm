package  HTML::Robot::Scrapper::UserAgent::Base;
use Moose;

has robot => ( is => 'rw', );
has engine => ( is => 'rw', );

sub normalize_url {
    my ( $self, $url ) = @_;
    return $self->engine->normalize_url( $self->robot, $url );
}

before 'visit' => sub {
    my ( $self ) = @_; 
    $self->robot->benchmark->method_start('visit');
};

sub visit {
    my ( $self, $item ) = @_;
    return $self->engine->visit( $self->robot , $item );
};

after 'visit' => sub {
    my ( $self ) = @_; 
    $self->robot->benchmark->method_finish('visit');
};

sub headers {
    my ( $self, $headers ) = @_;
    return $self->engine->_headers( $self->robot, $headers );
}

sub request_headers {
    my ( $self, $headers ) = @_;
    return $self->engine->_request_headers( $self->robot, $headers );
}

sub response_headers {
    my ( $self, $headers ) = @_;
    return $self->engine->_response_headers( $self->robot, $headers );
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

sub url { 
    my ( $self, $url ) = @_;
    return $self->engine->_url( $self->robot, $url );
}

1;
