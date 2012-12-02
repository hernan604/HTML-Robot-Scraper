package HTML::Robot::Scraper::EngineQueue;
use Moose::Role;


has queue_engine => (
    is => 'rw',
    isa => 'Any',
    builder => '_build_queue_engine',
);


sub _build_queue_engine {
    my ( $self ) = @_;
    Class::MOP::load_class( $self->engines->{queue} );
    $self->queue_engine( $self->engines->{queue}->new );
}

# The engines must implement these methods

sub queue_size {
    my ( $self ) = @_;
    return $self->queue_engine->queue_size( @_ );
}

sub queue_get_item {
    my ( $self ) = @_;
    return $self->queue_engine->queue_get_item( @_ );
}

sub append {
    my ( $self, $method, $url, $args ) = @_;
    $self->queue_engine->append( @_ );
}

sub prepend {
    my ( $self, $method, $url, $args ) = @_;
    $self->queue_engine->prepend( @_ );
}

1;
