package HTML::Robot::Scraper::Reader::BBC;
#use Moose;
#with qw(Jungle::Spider);
use Moose::Role;
use Data::Printer;
use Digest::SHA qw(sha1_hex);

has startpage => (
    is => 'rw',
    isa => 'Str',
    default => 'http://www.bbc.co.uk/',
);

sub start {
    my ( $self ) = @_;
    warn "**** Inicializado BBC ****";
}

sub on_start {
    my ( $self ) = @_;
    $self->append( search => $self->startpage );
#   warn p $self->url_list;
}

sub search {
    my ( $self ) = @_;
    warn " ON SEARCH ";
    my $title = $self->tree->findnodes( '//title' );
    warn $title;
    $self->writer->url( $self->current_page );
    $self->writer->html( sha1_hex($self->html_content) );
    $self->writer->save();
#   my $news = $self->tree->findnodes( '//div[@class="detalhes"]/h1/a' );
#   foreach my $item ( $news->get_nodelist ) {
#        my $url = $item->attr( 'href' );
#        $self->prepend( detail => $url ); #  append url on end of list
#   }
}

sub on_link {
    my ( $self, $url ) = @_;
#   warn '  ==> '.$url;
    if ( $url =~ m{^http://www.bbc.co.uk}ig ) {
        $self->prepend( search => $url ); #  append url on end of list
    }
}

sub detail {
    my ( $self ) = @_;
    warn $self->tree->findvalue( '//h1' );
#   $self->data->author( $self->tree->findvalue( '//div[@class="bb-md-noticia-autor"]' ) );
#   $self->data->webpage( $self->current_page );
#   $self->data->content( $content );
#   $self->data->title( $self->tree->findvalue( '//title' ) );
#   $self->data->meta_keywords( $self->tree->findvalue( '//meta[@name="keywords"]/@content' ) );
#   $self->data->meta_description( $self->tree->findvalue( '//meta[@name="description"]/@content' ) );
#   $self->data->save;
}


1;

