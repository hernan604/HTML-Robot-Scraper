package HTML::Robot::Scrapper::Cache::Default;
use Moo;

has cache => (
    is      => 'rw',
);

sub get {
    my ( $self, $key, $options ) = @_;
}

sub set {
    my ( $self, $key, $data, $options  ) = @_;
}

sub remove {
    my ( $self, $key ) = @_;
}

sub expire {
    my ( $self, $key ) = @_;
}

sub compute {
    my ( $self, $key, $options, $code ) = @_;
}

1;
