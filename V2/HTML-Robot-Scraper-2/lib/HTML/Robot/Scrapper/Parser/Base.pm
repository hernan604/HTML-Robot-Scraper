package  HTML::Robot::Scrapper::Parser::Base;
use Moo;

has robot => ( is => 'rw', );
has engine => ( is => 'rw', );

sub content_types {
    my ( $self ) = @_;
    return $self->engine->content_types;
}

1;
