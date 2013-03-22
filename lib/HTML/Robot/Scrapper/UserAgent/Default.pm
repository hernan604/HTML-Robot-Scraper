package  HTML::Robot::Scrapper::UserAgent::Default;
use Moo;
use Data::Printer;
use HTTP::Tiny;
use HTTP::Headers::Util qw(split_header_words);
use Digest::SHA1  qw(sha1 sha1_hex sha1_base64);

has headers => ( is => 'rw' );
has content => ( is => 'rw' );
has content_type => ( is => 'rw', );
has charset => ( is => 'rw', );
has current_page => ( is => 'rw', );
has ua => ( is => 'rw', default => sub { HTTP::Tiny->new() } );

sub _headers {
    my ( $self, $robot, $headers ) = @_;
    $self->headers( $headers ) if defined $headers;
    return $self->headers;
}

sub _content {
    my ( $self, $robot, $content ) = @_;
    $self->content( $content ) if defined $content;
    return $self->content;
}

sub _content_type {
    my ( $self, $robot, $content_type ) = @_;
    $self->content_type( $content_type ) if defined $content_type;
    return $self->content_type;
}

sub _charset {
    my ( $self, $robot, $charset ) = @_;
    $self->charset( $charset ) if defined $charset;
    return $self->charset;
}

sub _current_page {
    my ( $self, $robot, $url ) = @_;
    $self->current_page( $url ) if defined $url;
    return $self->current_page;
}

#visit the url and load into xpath and redirects to the method

=head2 visit
Will visit the url you appended/prepended to the queue
ex.

$robot->queue->append( search => 'http://www.url.com',{
    passed_key_values => {
        some   => 'vars i collected here...... and ....',
        i_will => 'pass them to the next page because ...',
        i_need => 'stuff from this page and the other '
    },
    request => [ <---- OPTIONAL... force custom request
        'GET',
        'http://www.lopes.com.br/imoveis/busca/-/'.$estado.'/-/-/-/aluguel-de-0-a-10000/de-0-ate-1000-m2/-/60',
        {
            headers => {
                'Content-Type' => 'application/x-www-form-urlencoded',
            },
            content => '',
        }
    ]
} );
=cut

sub visit {
    my ( $self, $robot, $item ) = @_;
    if ( $robot->cache->is_active ) {
        my $sha1 = Digest::SHA1->new;
        $sha1->add( $item->{ url } );
        my $sha1_key = $sha1->hexdigest;
        my $res = $robot->cache->get( $sha1_key );
        if ( ! $res ) {
            $res = $self->_visit( $robot, $item );
            $robot->cache->set( $sha1_key, $res );
            $self->parse_response( $robot, $res ); #todo: passar parametros melhor. ex: 10minutos pro cache..
            return $res;
        } else {
            $self->parse_response( $robot, $res );
            return $res;
        }
    } else {
        my $res = $self->_visit( $robot, $item );
        $self->parse_response( $robot, $res );
        return $res;
    }
}

sub _visit {
    my ( $self, $robot, $item ) = @_; 
    my $res = undef;
    if ( exists $item->{ request } and
        ref $item->{ request } eq ref [] )
    {
        $res = $self->ua->request( @{ $item->{ request } } );
    }
    else
    {
        $res = $self->ua->get( $item->{ url } );
    }
    $self->parse_response( $robot, $res );
    return $res;
}


sub parse_response {
    my ( $self, $robot, $res ) = @_; 
    my $headers = $res->{ headers };
    $self->content( $res->{ content } );
    $self->parse_content( $robot, $res );
}

sub parse_content {
    my ( $self, $robot, $res ) = @_;
    my $content_types_avail = $robot->parser->content_types;
    #set headers
    $self->headers( $res->{ headers } );
    #content type
    my $content_type =$res->{headers}->{'content-type'};
    $self->content_type( $content_type );
    #charset
    my $content_charset = $self->charset_from_headers( $res->{ headers } );
    $self->charset( $content_charset );


    foreach my $ct (keys $content_types_avail ) {
        foreach my $parser ( @{ $content_types_avail->{$ct} } ) {
            next unless $content_type =~ m/^$ct/ig;
            my $parse_method = $parser->{parse_method};
#           my $content = $res->{content};
            $robot->parser->engine->$parse_method( $robot, $self->content );
        }
    }
#   foreach my $ct ( keys $self->parser_content_type ) {
#       if ( $self->response->{ headers }->{'content-type'} =~ m|^$ct|g ) {
#           my $parser_method = $self->parser_methods->{ $self->parser_content_type->{ $ct } };
#           $self->$parser_method();
#       }
#   }
#   my $reader_method = $item->{method};
#   $self->$reader_method;    #redirects back to method
}

sub charset_from_headers {
    my ( $self, $headers ) = @_;
    my $ct = $headers->{'content-type'};
    my $charset ;
    if ( $ct =~ m/charset=([^;|^ ]+)/ig ) {
        $charset = $1;
    }
    return $charset;
}

sub normalize_url {
    my ( $self, $robot, $url ) = @_;
#   if (       ref $self->before_normalize_url eq ref {}
#       and exists $self->before_normalize_url->{is_active}
#              and $self->before_normalize_url->{is_active} == 1
#       and exists $self->before_normalize_url->{code}
#       ) {
#       $url = $self->before_normalize_url->{code}->( $url );
#   }
    if ( defined $url ) {
        $self->current_page( $url ) if ! defined $self->current_page;
        my     $final_url = URI->new_abs( $url , $self->current_page );
        return $final_url->as_string();
    }
}

1;
