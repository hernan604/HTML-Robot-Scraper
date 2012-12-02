package HTML::Robot::Scraper::Parser::HTML::TreeBuilder::XPath;
use Moose::Role;
use HTML::TreeBuilder::XPath;

has tree => (
    is  => 'rw',
    isa => 'HTML::TreeBuilder::XPath',
);

sub parse_xpath {
    my ($self) = @_;
    my $tree_xpath = HTML::TreeBuilder::XPath->new;
    $self->tree->delete
      if ( defined $self->tree
        and $self->tree->isa('HTML::TreeBuilder::XPath') );
    $self->tree( $tree_xpath->parse( $self->html_content ) );
}

after 'visit' => sub {
    my ( $self ) = @_; 
    $self->search_page_urls();
};

sub search_page_urls {
    my ($self) = @_; #search links and pass them to on_link method within the crawlers
    my $results = $self->tree->findnodes('//a');
    foreach my $item ( $results->get_nodelist ) {
        my $url = $item->attr('href');
        if ( defined $url and $url ne '' ) {
            my $url = $self->normalize_url( $url );
            $self->on_link($url)
              ;    #calls on_link and lets the user append or not to methods
        }
    }
}


1;

