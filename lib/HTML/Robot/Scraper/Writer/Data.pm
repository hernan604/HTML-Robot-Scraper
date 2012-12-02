package HTML::Robot::Scraper::Writer::Data;
use Moose;
use File::Slurp;

my $attrs = {
  url => {
    is => 'rw',
    isa => 'Any',
    cleanup => sub {
      my ( $self, $attr ) = @_; 
      $self->$attr(undef);
    },
  },
  html => {
    is => 'rw',
    isa => 'Any',
    cleanup => sub {
      my ( $self, $attr ) = @_; 
      $self->$attr(undef);
    },
  }
};
foreach my $attr ( keys $attrs ) {
    has $attr => (
      is => $attrs->{ $attr }->{is},
      isa => $attrs->{ $attr }->{isa},
    ); 
}

after 'save' => sub {
    my ( $self ) = @_; 
    $self->cleanup();
};

sub cleanup {
    my ( $self ) = @_; 
    warn "CLEANUP";
    foreach my $attr ( keys $attrs ) {
        $attrs->{ $attr }->{cleanup}->( $self, $attr );
    }
}

sub save {
    my ( $self ) = @_; 
    warn "PROOF OF SAVE";
    warn $self->url;
    warn $self->html;
    write_file( 'saida', { append => 1, }, $self->html . "|" . $self->url ."\n" );
    warn "depois só limpar e continuar";
}

1;
