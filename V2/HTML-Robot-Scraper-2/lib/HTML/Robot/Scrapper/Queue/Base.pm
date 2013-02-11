package  HTML::Robot::Scrapper::Queue::Base;
use Moo;
use Data::Printer;

has robot => ( is => 'rw', );
has engine => ( is => 'rw', );

## API METHODS
# The engines must implement these methods

sub queue_size {
    my ( $self ) = @_;
    return $self->engine->queue_size( $self->robot, @_ );
}

=head2
is expected to shift from the array of urls to be visit.
=cut

sub queue_get_item {
    my ( $self ) = @_;
    return $self->engine->queue_get_item( $self->robot, @_ );
}

sub append {
    my ( $self, $method, $url, $args ) = @_;
    $self->engine->append(
        $self->robot,
        $method,
        $self->robot->useragent->normalize_url($url),
        $args,
    );
}

sub prepend {
    my ( $self, $method, $url, $args ) = @_;
    $self->engine->prepend(
        $self->robot,
        $method,
        $self->robot->useragent->normalize_url($url),
        $args,
    );
}


1;
