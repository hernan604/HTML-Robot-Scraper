package HTML::Robot::Scraper::Engine::Queue::Array;
use Moose;

####
### $method is the perl function that will handle this request
### $url is the next url to be accessed and handled by $method
### $query_params is an ARRAYREF, used for POST.
###     ie: [ 'formfield1_name' =>'Joe', 'formfield2_age' => 50, ]
### $rerefer_key_val is an HASHREF used to pass values from one page to the next page
###     ie: { stuff_on_page1 =>
###         'Something from page one that should be used on another page' }
sub append {
    my ( $self, $caller, $method, $url, $args ) = @_;
    my $query_params = $args->{query_params}
      if ( exists $args->{query_params} );
    my $passed_key_values = $args->{passed_key_values}
      if ( exists $args->{passed_key_values} );
    my $url_normalized = $caller->normalize_url($url);
    if (    !exists $caller->url_visited->{$url_normalized}
        and !exists $caller->url_list_hash->{$url_normalized} )
    {

        #inserts stuff into @{ $caller->url_list } which is handled by 'visit'
        push(
            @{ $caller->url_list },
            {
                method            => $method,
                url               => $url_normalized,
                query_params      => $query_params,
                passed_key_values => $passed_key_values,
            }
        );
        $caller->url_list_hash->{$url_normalized} = 1;
    }
    warn "APPENDED '$method' : '$url' ";
}

####
### $method is the perl function that will handle this request
### $url is the next url to be accessed and handled by $method
### $query_params is an ARRAYREF, used for POST.
###     ie: [ 'formfield1_name' =>'Joe', 'formfield2_age' => 50, ]
### $rerefer_key_val is an HASHREF used to pass values from one page to the next page
###     ie: { stuff_on_page1 =>
###         'Something from page one that should be used on another page' }
sub prepend {
    my ( $self, $caller, $method, $url, $args ) = @_;
    my $query_params = $args->{query_params}
      if ( exists $args->{query_params} );
    my $passed_key_values = $args->{passed_key_values}
      if ( exists $args->{passed_key_values} );
    my $url_normalized = $caller->normalize_url($url);
    if (    !exists $caller->url_visited->{$url_normalized}
        and !exists $caller->url_list_hash->{$url_normalized} )
    {

        #inserts stuff into @{ $caller->url_list } which is handled by 'visit'
        unshift(
            @{ $caller->url_list },
            {
                method            => $method,
                url               => $url_normalized,
                query_params      => $query_params,
                passed_key_values => $passed_key_values,
            }
        );
        $caller->url_list_hash->{$url_normalized} = 1;
    }
    warn "PREPENDED '$method' : '$url' ";
}

sub queue_size {
    my ( $self, $caller ) = @_;
    return scalar @{ $caller->url_list };
}

sub queue_get_item {
    my ( $self, $caller ) = @_;
    return shift( @{ $caller->url_list } );
}

sub clean_all {
    my ( $self ) = @_;
    #dumb method because its an aray, so it was just created
}



1;
