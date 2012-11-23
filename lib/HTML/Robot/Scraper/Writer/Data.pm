package HTML::Robot::Scraper::Writer::Data;
use Moose;

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
    warn "depois só limpar e continuar";
}

1;
