package HTML::Robot::Scrapper::Queue::Redis;
use Moose;
use URI;
use Data::Printer;
use JSON::XS;

has url_list => (
    is      => 'rw',
#   isa     => 'ArrayRef',
    default => sub { return []; },
);

has url_list_hash => (
    is      => 'rw',
#   isa     => 'HashRef',
    default => sub { return {}; },
);

has url_visited => (
    is      => 'rw',
#   isa     => 'HashRef',
    default => sub { {} },
);

has [ qw/queue_name client/ ] => ( is => 'rw' );

=head1 DESCRIPTION

This is the queue class. It is responsible of managing the queue.

It uses the api from HTML::Robot::Scrapper::Queue::Base 

=cut

sub is_visited {
    my ( $self, $robot, $url ) = @_; 
    my $is_visited = $self->client->hget(
      $self->url_visited , $url
    );    #TODO: deve ficar no arquivo de config dentro da secao redis.
    return 1 if defined $is_visited and $is_visited ne '';
    return 0;
}

####
### $method is the perl function that will handle this request
### $url is the next url to be accessed and handled by $method
### $query_params is an ARRAYREF, used for POST.
### ie: [ 'formfield1_name' =>'Joe', 'formfield2_age' => 50, ]
### $rerefer_key_val is an HASHREF used to pass values from one page to the next page
### ie: { stuff_on_page1 =>
### 'Something from page one that should be used on another page' }
sub append {
    my ( $self, $robot, $method, $url, $args ) = @_;
    if ( ! $self->is_visited( $robot, $url ) or exists $args->{request} )
    {
        $args = {} if ! defined $args;
        #inserts stuff into @{ $robot->url_list } which is handled by 'visit'
        my $url_args = {
                method              => $method,
                url                 => $url,
        };
        foreach my $k ( keys %$args ) {
            $url_args->{$k} = $args->{$k};
        }
        $self->insert_on_end( $robot, $url_args );
        $self->url_list_hash->{$url} = 1;
        print "APPENDED '$method' : '$url' \n";
    }
}

####
### $method is the perl function that will handle this request
### $url is the next url to be accessed and handled by $method
### $query_params is an ARRAYREF, used for POST.
### ie: [ 'formfield1_name' =>'Joe', 'formfield2_age' => 50, ]
### $rerefer_key_val is an HASHREF used to pass values from one page to the next page
### ie: { stuff_on_page1 =>
### 'Something from page one that should be used on another page' }
sub prepend {
    my ( $self, $robot, $method, $url, $args ) = @_;
    if ( ! $self->is_visited( $robot, $url ) or exists $args->{request} )
    {
        $args = {} if ! defined $args;
        #inserts stuff into @{ $robot->url_list } which is handled by 'visit'
        my $url_args = {
                method              => $method,
                url                 => $url,
        };
        foreach my $k ( keys %$args ) {
            $url_args->{$k} = $args->{$k};
        }
        $self->insert_on_begining( $robot, $url_args );
        $self->url_list_hash->{$url} = 1;
        print "PREPENDED '$method' : '$url' \n";
    }
}

sub insert_on_end {
    my ( $self, $robot, $url_args ) = @_;
    my $count_items = $self->client->rpush(
        $self->queue_name
        , encode_json( {
            method            => $url_args->{method},
            url               => $url_args->{ url },
            args              => $url_args->{ args },
        } )
    );
    $self->client->hset(
        $self->url_visited,
        $url_args->{url} => 1,
    );
}

sub insert_on_begining {
    my ( $self, $robot, $url_args ) = @_;
    my $count_items = $self->client->lpush( $self->queue_name ,
        encode_json( {
            method            => $url_args->{method},
            url               => $url_args->{ url },
            args              => $url_args->{ args },
        } )
    );
    $self->client->hset( $self->url_visited,
        $url_args->{url} => 1,
    );
}

sub queue_size {
    my ( $self, $robot ) = @_;
    return $self->client->llen( $self->queue_name );
}

sub queue_get_item {
    my ( $self, $robot ) = @_;
    my $item = $self->client->lpop( $self->queue_name );
    return decode_json ( $item ) if defined $item;
    return;
}

sub clean_all {
    my ( $self ) = @_;
    my %hash = $self->client->hgetall( $self->url_visited );
    foreach my $k ( keys %hash ) {
      $self->client->hdel( $self->url_visited , $k );
    }
}

sub add_visited {
    my ( $self, $robot, $url ) = @_; 
    $self->client->hset( $self->url_visited, $url => 1 );#set as visited
}
    

#   sub BUILDARGS {
#       my ( $self , $args ) = @_; 
#       warn "CLASS REDIS";
#   #   warn p $args;
#   #   warn p $self->client;
#       warn "CLASS REDIS";
#       warn "CLASS REDIS";
#   }


1;
