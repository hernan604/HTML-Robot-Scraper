package HTML::Robot::Scrapper::Cache::Base;
use Moo;

has robot => ( is => 'rw', );
has engine => ( is => 'rw', );

sub read {
    my ( $self ) = @_;
}

sub write {
    my ( $self ) = @_;
}

sub reset {
    my ( $self ) = @_;
}

1;
