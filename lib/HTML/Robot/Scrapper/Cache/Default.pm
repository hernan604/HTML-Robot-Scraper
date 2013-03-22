package HTML::Robot::Scrapper::Cache::Default;
use Moo;

has engine => (
    is      => 'rw',
);

has is_active => (
    is      => 'rw',
    default => sub { 0 },
);

sub get {
#    my ( $self, $key, $options ) = @_;
    my ( $self ) = shift;
    return $self->engine->get( @_ );
}

sub set {
    my ( $self,  ) = shift;
#   my ( $self, $key, $data, $options  ) = @_;
    $self->engine->set( @_ );
}

sub remove {
#   my ( $self, $key ) = @_;
    my ( $self ) = shift;
    $self->engine->remove( @_ );
}

sub expire {
    my ( $self, $key ) = @_;
}

sub compute {
    my ( $self, $key, $options, $code ) = @_;
}

1;
