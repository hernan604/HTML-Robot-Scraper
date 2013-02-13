package HTML::Robot::Scrapper::Parser::HTML::TreeBuilder::XPath;
use Moo::Role;
use HTML::TreeBuilder::XPath;
use Data::Printer;

has tree => (
    is => 'rw',
);

=head2 parse_xpath

you must indicate which method will be used to parse the received content.

see HTML::Robot::Scrapper::Parser::Default

=cut

sub parse_xpath {
    my ($self, $robot, $content ) = @_;
    my $tree_xpath = HTML::TreeBuilder::XPath->new;
    $self->tree->delete
      if ( defined $self->tree
        and $self->tree->isa('HTML::TreeBuilder::XPath') );
    $self->tree( $tree_xpath->parse( $content ) );
}

after 'parse_xpath' => sub {
    my ( $self, $robot, $content ) = @_;
    $self->search_page_urls( $robot );
};

sub search_page_urls {
    my ($self, $robot ) = @_; #search links and pass them to on_link method within the crawlers
    my $results = $self->tree->findnodes('//a');
    foreach my $item ( $results->get_nodelist ) {
        my $url = $item->attr('href');
        if ( defined $url and $url ne '' ) {
            my $url = $robot->useragent->normalize_url( $url );
            $robot->reader->on_link($url)
              ;    #calls on_link and lets the user append or not to methods
        }
    }
}

1;
