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

1;
