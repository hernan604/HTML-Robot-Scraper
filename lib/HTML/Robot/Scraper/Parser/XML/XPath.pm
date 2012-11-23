package HTML::Robot::Scraper::Parser::XML::XPath;
use Moose::Role;
use XML::XPath;

has xml => (
    is  => 'rw',
    isa => 'Any',
);

sub parse_xml {
    my ($self) = @_;
    my $xml = XML::XPath->new( xml => $self->html_content );
    $self->xml( $xml );
}


1;

