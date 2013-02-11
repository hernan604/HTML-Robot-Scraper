package  HTML::Robot::Scrapper::UserAgent::Default;
use Moo;
use Data::Printer;
use HTTP::Tiny;
use HTTP::Headers::Util qw(split_header_words);

has headers => ( is => 'rw' );
has content => ( is => 'rw' );
has content_type => ( is => 'rw', );
has charset => ( is => 'rw', );
has current_page => ( is => 'rw', );

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
sub visit {
    my ( $self, $robot, $item ) = @_;
    warn "HTTP TINY";
#   warn p $item;
    my $res = HTTP::Tiny->new->get( $item->{ url } );
    my $headers = $res->{ headers };
    $self->content(
        $robot->encoding->safe_encode( $headers , $res->{ content } )
    );
    $self->parse_content( $robot, $res );
    return $res;
}

sub parse_content {
    my ( $self, $robot, $res ) = @_;
    my $content_types_avail = $robot->parser->content_types;
    my $content_type =$res->{headers}->{'content-type'};
    $self->content_type( $content_type );

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
