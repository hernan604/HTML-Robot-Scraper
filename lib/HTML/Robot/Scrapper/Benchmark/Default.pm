package HTML::Robot::Scrapper::Benchmark::Default;
use Moo;
use DateTime;
use Data::Printer;
use Time::HiRes qw(gettimeofday tv_interval);

has 'values' => ( is => 'rw' );

sub BUILD {
    my ( $self ) = @_;
    $self->values({});
}

sub method_start {
    my ( $self, $method, $label ) = @_;
    my $values = $self->values;
    $values->{ $method } = {
#     start => DateTime->now(),
      start => [gettimeofday],
    };
    $self->values( $values );
}

sub method_finish {
    my ( $self, $method, $label ) = @_;
    my $values = $self->values;
#   $values->{ $method }->{ finish  }  = DateTime->now();
    $values->{ $method }->{ finish  }  = [gettimeofday];
#   $values->{ $method }->{ duration } = $values->{ $method }->{ finish } - $values->{ $method }->{ start } ;
    $values->{ $method }->{ duration } = tv_interval ( $values->{ $method }->{ start }, $values->{ $method }->{ finish } ); ;
    my $text = ( $label ) ? $label : $method;
    warn " => ". $text . ": ". $values->{ $method }->{ duration } . ' seconds';
    $self->values( $values );
}

1;
