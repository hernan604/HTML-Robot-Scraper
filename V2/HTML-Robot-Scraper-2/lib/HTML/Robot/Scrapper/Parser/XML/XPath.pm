package HTML::Robot::Scrapper::Parser::XML::XPath;
use Moo::Role;
use XML::XPath;

has xml => (
    is => 'rw',
#   isa => 'Any',
);
=head2 parse_xml
you must indicate which method will be used to parse the received content.
see HTML::Robot::Scrapper::Parser::Default
=cut
sub parse_xml {
    my ($self, $robot, $content ) = @_;
    my $xml = XML::XPath->new( xml => $content );
    $self->xml( $xml );
}

1;

