package HTML::Robot::Scrapper::Log::Base;
use Moo;

has robot => ( is => 'rw', );
has engine => ( is => 'rw', );

sub write {
    my ( $self ) = @_;
}

1;
