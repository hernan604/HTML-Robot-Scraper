package HTML::Robot::Scraper::Engine;
use Moose::Role;

has queue_engine => (
    is => 'rw',
    isa => 'Any',
    builder => '_build_queue_engine',
);


sub _build_queue_engine {
    my ( $self ) = @_;
    Class::MOP::load_class( $self->engines->{queue} );
    $self->queue_engine( $self->engines->{queue}->new );
}


## API METHODS
# The engines must implement these methods

sub queue_size {
    my ( $self ) = @_;
    return $self->queue_engine->queue_size( @_ );
}

sub queue_get_item {
    my ( $self ) = @_;
    return $self->queue_engine->queue_get_item( @_ );
}

sub append {
    my ( $self, $method, $url, $args ) = @_;
    $self->queue_engine->append( @_ );
}

sub prepend {
    my ( $self, $method, $url, $args ) = @_;
    $self->queue_engine->prepend( @_ );
}

### USER AGENT ENGINE #######
has ua_engine => (
    is => 'rw',
    isa => 'Any',
    builder => '_build_ua_engine',
);

sub _build_ua_engine {
    my ( $self ) = @_;
    Class::MOP::load_class( $self->engines->{user_agent} );
    $self->ua_engine( $self->engines->{user_agent}->new );
}

sub visit {
    my ( $self, $item ) = @_;
    warn 'TOTAL URLS IN LIST: ' . scalar @{ $self->url_list };
    return
      if exists $self->url_visited->{ $item->{url} };    #return if not visited
    $self->url_visited->{ $item->{url} } = 1;            #set as visited
    $self->html_content(undef);
    $self->response( undef );
    warn "VISITING $item->{ method } : $item->{ url }";
    $self->current_page( $item->{url} );    #sets the page we are visiting
    $self->current_status( '' );

    my $res = $self->ua_engine->visit( $item );
    if ( ref $res ne ref {} ) {
      warn "\$res tem que ser um hash, ao estilo HTTP::Tiny";
      die;
    }
    $self->response( $res );
    $self->html_content( $self->safe_utf8( $res->{ content } ) );
}

##
# will try to parse stuff based on content type and configurations
##
after 'visit' => sub {
    my ( $self, $item ) = @_; 
#   warn "after visit: PARSE stuff from \$self->html_content";
    foreach my $ct ( keys $self->parser_content_type ) {
        if ( $self->response->{ headers }->{'content-type'} =~ m|^$ct|g ) {
            my $parser_method = $self->parser_methods->{ $self->parser_content_type->{ $ct } };
            $self->$parser_method();
        }
    }
    my $reader_method = $item->{method};
    $self->$reader_method;    #redirects back to method
};


1;
