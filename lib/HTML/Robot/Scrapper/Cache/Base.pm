package HTML::Robot::Scrapper::Cache::Base;
use Moo;

has robot => ( is => 'rw', );
has engine => ( is => 'rw', );
has is_active => (
    is      => 'rw',
    default => sub { 0 },
);

sub get {
    my ( $self ) = shift;
    $self->engine->get( @_ );
}

sub set {
    my ( $self ) = shift;
    $self->engine->set( @_ );
}

sub remove {
    my ( $self ) = shift;
    $self->engine->remove( @_ );
}

sub expire {
    my ( $self ) = shift;
    $self->engine->expire( @_ );
}

sub compute {
    my ( $self ) = shift;
    $self->engine->compute( @_ );
}

1;
