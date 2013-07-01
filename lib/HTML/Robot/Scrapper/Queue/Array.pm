package HTML::Robot::Scrapper::Queue::Array;
use Moose;
use URI;
use Data::Printer;

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

=head1 DESCRIPTION

This is the queue class. It is responsible of managing the queue.

It uses the api from HTML::Robot::Scrapper::Queue::Base 

=cut



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
    if ( (   !exists $self->url_visited->{$url}
         and !exists $self->url_list_hash->{$url} ) or exists $args->{request} )
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
        push(
            @{ $self->url_list },
            $url_args
        );
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
    if ( ( !exists $self->url_visited->{$url}
       and !exists $self->url_list_hash->{$url} ) or exists $args->{request} )
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
        unshift(
            @{ $self->url_list },
            $url_args
        );
        $self->url_list_hash->{$url} = 1;
        print "PREPENDED '$method' : '$url' \n";
    }
}

sub queue_size {
    my ( $self, $robot ) = @_;
    return scalar @{ $self->url_list };
}

sub queue_get_item {
    my ( $self, $robot ) = @_;
    return shift( @{ $self->url_list } );
}

sub clean_all {
    my ( $self ) = @_;
    #dumb method because its an aray, so it was just created
}


1;
