package HTML::Robot::Scraper::EngineUserAgent;
use Moose::Role;
use File::Slurp;
use Digest::SHA qw(sha1_hex);
use JSON::XS;

has ua_engine => (
    is => 'rw',
    isa => 'Any',
    builder => '_build_ua_engine',
);

sub _build_ua_engine {
    my ( $self ) = @_;
warn p $self->engines;
    my $obj = $self->engines->{user_agent};
    Class::MOP::load_class( $obj->{class} );
    $self->ua_engine( $obj->{class}->new(
        ( exists $obj->{constructor_args} ) ?
        $obj->{constructor_args} : ()
    ) );
	warn p $self->ua_engine;
warn "^^ User Agent engine BUILT !!! ^^";
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

    my $res;
    if (
        defined $self->local_cache
        && $self->local_cache->{enabled} == 1
        && -e $self->local_cache->{directory} .'/' . sha1_hex( $item->{ url } )
       ) {
        my $content = read_file( $self->local_cache->{directory} .'/' . sha1_hex( $item->{ url } ) );
        $res = decode_json $content;
    } else {
        $res = $self->ua_engine->visit( $item );
        if ( defined $self->local_cache && $self->local_cache->{enabled} == 1 ) {
            write_file( $self->local_cache->{directory} .'/'. sha1_hex( $item->{url} ), encode_json $res);
        }
    }

    if ( ref $res ne ref {} ) {
      warn "\$res response must be hashed, just like response from HTTP::Tiny";
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
#use Data::Printer;      warn p $self->response;
        if ( $self->response->{ headers }->{'content-type'} =~ m|^$ct|g ) {
            my $parser_method = $self->parser_methods->{ $self->parser_content_type->{ $ct } };
            $self->$parser_method();
        }
    }
    my $reader_method = $item->{method};
    $self->$reader_method;    #redirects back to method
};


1;
