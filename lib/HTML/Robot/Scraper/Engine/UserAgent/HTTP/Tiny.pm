package HTML::Robot::Scraper::Engine::UserAgent::HTTP::Tiny;
use Moose;
use Data::Printer;
use HTTP::Tiny;


#visit the url and load into xpath and redirects to the method
sub visit {
    my ( $self, $item ) = @_;
    warn "HTTP TINY";
    warn p $item;
    my $res = HTTP::Tiny->new->get( $item->{ url } );
    #warn p $res;
    return $res;
}

has ua => (
    is => 'rw',
    isa => 'Any',
    default => sub {
        return HTTP::Tiny->new();
    },
);

1;
