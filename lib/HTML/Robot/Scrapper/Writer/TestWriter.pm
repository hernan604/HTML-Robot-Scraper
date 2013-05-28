package HTML::Robot::Scrapper::Writer::TestWriter;
use Moo;
use v5.10;

my $FIELDS = {
    data_to_save => { ##use anything
        is => 'rw',
    },
};

foreach my $f ( keys $FIELDS ) {
    has $f => ( is => $FIELDS->{ $f }->{ is } );
}

sub save_data {
    my ( $self, $data ) = @_; 
    $self->data_to_save( $data );
    say "Data saved...into memory!";
}

1;
