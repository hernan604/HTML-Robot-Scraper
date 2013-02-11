package HTML::Robot::Scrapper::Reader::TestReader;
use Moo;
#use Moose::Role;
use Data::Printer;
use Digest::SHA qw(sha1_hex);

has startpage => (
    is => 'rw',
#   isa => 'Str',
    default => sub { return 'http://www.bbc.co.uk/'} ,
);

sub start {
    my ( $self ) = @_;
    warn "**** Inicializado BBC ****";
}

sub on_start {
    my ( $self, $robot ) = @_;
#   $robot->queue->append( search => $self->startpage );
    $robot->queue->append( search => 'http://www.zap.com.br/' ); #iso-8859-1
    warn p $robot;
#   warn p $self->url_list;
}

sub search {
    my ( $self, $robot ) = @_;
    my $title = $robot->parser->engine->tree->findvalue( '//title' );
#   my $title = $robot->parser->engine->tree->findnodes( '//title' );
#   warn p $robot->parser->engine->tree;
    warn $title;
    warn $title;
    warn $title;
    warn $robot->useragent->current_page;
#   $self->writer->url( $robot->instance->current_page );
#   $self->writer->html( sha1_hex($self->html_content) );
#   $self->writer->save();
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

sub on_finish {
    my ( $self ) = @_;
    warn "=> on_finish()";
}

1;
