package HTML::Robot::Scrapper::Writer::TestWriter;
use Moo;

my $FIELDS = {
    title => {
        is => 'rw',
    },
    url   => {
        is => 'rw',
    },
};

foreach my $f ( keys $FIELDS ) {
    has $f => ( is => $FIELDS->{ $f }->{ is } );
}

sub save_data {
    my ( $self ) = @_; 
    warn "=====================================================================";
    warn "method save_data from class HTML::Robot::Scrapper::Writer::TestWriter";
    foreach my $f ( keys $FIELDS ) {
        warn $f;
        warn $self->$f;
        warn "-----";
    }
    warn "save data";
    warn "save data";
}

1;
