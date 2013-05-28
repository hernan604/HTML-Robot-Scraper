package HTML::Robot::Scrapper;
use Moo;
use Class::Load ':all';
use Data::Dumper;
use Data::Printer;
use Try::Tiny;
use v5.10;

our $VERSION     = '0.01';

my $CUSTOMIZABLES = {
#   reader      => 'HTML::Robot::Scrapper::Reader',
#   writer      => 'HTML::Robot::Scrapper::Writer',
    benchmark   => 'HTML::Robot::Scrapper::Benchmark',
    cache       => 'HTML::Robot::Scrapper::Cache',
    log         => 'HTML::Robot::Scrapper::Log',
    parser      => 'HTML::Robot::Scrapper::Parser',
    queue       => 'HTML::Robot::Scrapper::Queue',
    useragent   => 'HTML::Robot::Scrapper::UserAgent',
    encoding    => 'HTML::Robot::Scrapper::Encoding',
    instance    => 'HTML::Robot::Scrapper::Instance',
};

=head1 ATTRIBUTES

=cut

=head2 reader
=cut
has reader => (
    is      => 'rw',
);

=head2 writer
=cut
has  writer => (
    is      => 'rw',
);

=head2 benchmark
=cut
has benchmark => (
    is      => 'rw',
);
=head2 chache
=cut
has cache => (
    is      => 'rw',
);
=head2 log
=cut
has log => (
    is      => 'rw',
);
=head2 parser
=cut
has parser => (
    is      => 'rw',
);
=head2 queue
=cut
has queue => (
    is      => 'rw',
);

=head2 useragent
=cut
has useragent => (
    is      => 'rw',
);

=head2 encoding
=cut
has encoding => (
    is      => 'rw',
);

=head2 instance
=cut
has instance => (
    is      => 'rw',
);



=head2 new

HTML::Robot::Scrapper->new({
    reader      => {class   => 'HTML::Robot::Scrapper::Reader::TestReader',
                    args    => {},                  },# or [] or any object
    writer      => {class   => 'HTML::Robot::Scrapper::Writer::TestWriter',
                    args    => {},                                       },
    benchmark   => {class   => 'Base',
                    args    => {},                                       },
    cache       => {class   => 'Base',
                    args    => {},                                       },
    log         => {class   => 'Base',
                    args    => {},                                       },
    parser      => {class   => 'Base',
                    args    => {},                                       },
    queue       => {class   => 'Base',
                    args    => {},                                       },
    useragent   => {class   => 'Base',
                    args    => {},                                       },
});

=cut

sub BUILDARGS {
    my ( $class, @args ) = @_;
    my $options = {@args};

    foreach my $option ( keys $CUSTOMIZABLES ) {
        &_load_custom_class( $options, $option, $CUSTOMIZABLES );
    }
    &_load_reader( $options );
    &_load_writer( $options );

    return $options;
};

sub _load_custom_class {
    my ( $options, $option, $CUSTOMIZABLES ) = @_; 
    my $base_class  = $CUSTOMIZABLES->{$option} .'::Base';
    my $engine_class = $CUSTOMIZABLES->{$option} .'::Default';
    if ( exists $options->{ $option } and
         exists $options->{ $option }->{ class } ) {
        $engine_class = $CUSTOMIZABLES->{$option}
            . '::' . $options->{ $option }->{ class };
    }

    #load base class interface
    try {
        $base_class = load_class( $base_class );
    } catch {
        say "Could not load base_class: " . $base_class;
    };
#say $base_class;

    #load custom engine
    try {
        $engine_class = load_class( $engine_class );
    } catch {
        $engine_class = load_class( $options->{ $option }->{ class } );
    };
#say $engine_class;
#say $option;
    my $args = $options->{$option}->{args}||{};
    say $option;
    say p $args;
    say '-----------------------';
    $options->{$option} = $base_class->new(
        engine => $engine_class->new( $args ),
        ( exists $options->{$option}->{args}->{is_active}) ?
          ( is_active => $options->{$option}->{args}->{is_active} ) : (),
    );
}

sub _load_reader {
    my ( $options ) = @_; 
    my $reader_class = load_class( $options->{ reader }->{ class } );
    $options->{reader} = $reader_class->new( $options->{ reader }->{ args } || {} );
}

sub _load_writer {
    my ( $options  ) = @_; 
    my $writer_class = load_class( $options->{ writer }->{ class } );
    $options->{writer} = $writer_class->new( $options->{ writer }->{ args } || {} );
}

=head2 before 'start'
    - give access to this class inside other custom classes
=cut

before 'start' => sub {
    my ( $self ) = @_;
    foreach my $k ( keys $CUSTOMIZABLES ) {
        #give access to this class inside other classes
        $self->$k->robot( $self );
    }
    $self->reader->robot( $self );
};

sub start {
    my ( $self ) = @_;
    $self->reader->on_start( $self );
    my $counter = 0;
    while ( my $item = $self->queue->queue_get_item ) {
        $self->benchmark->method_start('finish_in');

        say '--[ '.$counter++.' ]------------------------------------------------------------------------------';
        say ' url: '. $item->{ url } if exists $item->{ url };
        my $method = $item->{ method };
        my $res = $self->useragent->visit($item);

        #clean up&set passed_key_values
        $self->reader->passed_key_values( {} );
        $self->reader->passed_key_values( $item->{passed_key_values} )
            if exists $item->{passed_key_values};

        #clean up&set passed_key_values
        $self->reader->headers( {} );
        $self->reader->headers( $res->{headers} )
            if exists $res->{headers};

        #TODO: set the cookies in $self->reader->cookies
        # that way its possible to use and update 1 same cookie

        
        $self->benchmark->method_start( $method );
        try {
          $self->reader->$method( );
        } catch {};
        $self->benchmark->method_finish( $method );

        $self->benchmark->method_finish('finish_in', 'Total: ' );
    }
    $self->reader->on_finish( );
}

=head1 NAME

HTML::Robot::Scrapper - Your robot to parse webpages

=head1 SYNOPSIS

    package WWW::Tabela::Fipe::Parser;
    use Moo;

    with('HTML::Robot::Scrapper::Parser::HTML::TreeBuilder::XPath');
    with('HTML::Robot::Scrapper::Parser::XML::XPath');

    sub content_types {
        my ( $self ) = @_;
        return {
            'text/html' => [
                {
                    parse_method => 'parse_xpath',
                    description => q{
    The method above 'parse_xpath' is inside class:
    HTML::Robot::Scrapper::Parser::HTML::TreeBuilder::XPath
    },
                }
            ],
            'text/plain' => [
                {
                    parse_method => 'parse_xpath',
                    description => q{
    esse site da fipe responde em text/plain e eu preciso parsear esse content type.
    por isso criei esta classe e passei ela como parametro, sobreescrevendo a classe
    HTML::Robot::Scrapper::Parser::Default
    },
                }
            ],
            'text/xml' => [
                {
                    parse_method => 'parse_xml'
                },
            ],
        };
    }

    1;

    package FIPE;

    use HTML::Robot::Scrapper;
    #   use CHI;
    use HTTP::Tiny;
    use HTTP::CookieJar;

    my $robot = HTML::Robot::Scrapper->new (
        reader => { # REQ
            class => 'WWW::Tabela::Fipe',
        },
        writer => {class => 'WWW::Tabela::FipeWrite',}, #REQ
        benchmark => {class => 'Default'},
    #   cache => {
    #     class => 'Default',
    #     args => {
    #         is_active => 0,
    #         engine => CHI->new(
    #             driver => 'BerkeleyDB',
    #             root_dir => "/home/catalyst/WWW-Tabela-Fipe/cache/",
    #         ),
    #     },
    #   },
        log => {class => 'Default'},
        parser => {class => 'WWW::Tabela::Fipe::Parser'}, #custom for tb fipe. because they reply with text/plain content type
        queue => {class => 'Default'},
        useragent => {
            class => 'Default',
            args => {
                ua => HTTP::Tiny->new( cookie_jar => HTTP::CookieJar->new),
            }
        },
        encoding => {class => 'Default'},
        instance => {class => 'Default'},
    );

    $robot->start();

=head1 DESCRIPTION

This cralwer has been created to be extensible.

For example, after making a request call ( HTML::Robot::Scrapper::UserAgent::Default ) 

it will need to parse data.. and will use the response content type to parse that data

by default the class that handles that is: 

    package HTML::Robot::Scrapper::Parser::Default;
    use Moo;

    with('HTML::Robot::Scrapper::Parser::HTML::TreeBuilder::XPath'); #gives parse_xpath
    with('HTML::Robot::Scrapper::Parser::XML::XPath'); #gives parse_xml

    sub content_types {
        my ( $self ) = @_;
        return {
            'text/html' => [
                {
                    parse_method => 'parse_xpath',
                    description => q{
    The method above 'parse_xpath' is inside class:
    HTML::Robot::Scrapper::Parser::HTML::TreeBuilder::XPath
    },
                }
            ],
            'text/xml' => [
                {
                    parse_method => 'parse_xml'
                },
            ],
        };
    }

    1;

Another example is the Queue system, it has an api: HTML::Robot::Scrapper::Queue::Base and by default

uses: HTML::Robot::Scrapper::Queue::Array which works fine for 1 local instance. However, lets say i want a REDIS queue, so i could

implement HTML::Robot::Scrapper::Queue::Redis and make the crawler access a remote queue.. this way i can share a queue between many crawlers independently.

Just so you guys know, i have a redis module almost ready, it needs litle refactoring because its from another personal project. It will be released asap when i got time.

So, if that does not fit you, or you want something else to handle those content types, just create a new class and pass it on to the HTML::Robot::Scrapper constructor. ie:

    see the SYNOPSIS

By default it uses HTTP Tiny and useragent related stuff is in: 

    HTML::Robot::Scrapper::UserAgent::Default

=head1 Project Statys

The crawling works as expected, and works great. And the api will not change probably.

=head1 TODO

Implement the REDIS Queue to give as option for the Array queue. Array queue runs local/per instance.. and the redis queue can be shared and accessed by multiple machines!

Still need to implement the Log, proper Benchmark with subroutine tree and timing.

Allow parameters to be passed in to UserAgent (HTTP::Tiny on this case)

Better tests and docs.

=head1 Example 1 - Append some urls and extract some data

On this first example, it shows how to make a simple crawler... by simple i mean simple GET requests following urls... and grabbing some data.

    package HTML::Robot::Scrapper::Reader::TestReader;
    use Moo;
    with 'HTML::Robot::Scrapper::Reader';
    use Data::Printer;
    use Digest::SHA qw(sha1_hex);

    ## The commented stuff is useful as example

    has startpage => (
        is => 'rw',
        default => sub { return 'http://www.bbc.co.uk/'} ,
    );

    has array_of_data => ( is => 'rw', default => sub { return []; } );

    has counter => ( is => 'rw', default => sub { return 0; } );

    sub on_start {
        my ( $self ) = @_;
        $self->append( search => $self->startpage );
        $self->append( search => 'http://www.zap.com.br/' ); 
        $self->append( search => 'http://www.uol.com.br/' );
        $self->append( search => 'http://www.google.com/' );
    }

    sub search {
        my ( $self ) = @_;
        my $title = $self->robot->parser->engine->tree->findvalue( '//title' );
        my $h1 = $self->robot->parser->engine->tree->findvalue( '//h1' );
        warn $title;
        warn p $self->robot->useragent->url ;
        push( @{ $self->array_of_data } , 
            { title => $title, url => $self->robot->useragent->url, h1 => $h1 } 
        );
    }

    sub on_link {
        my ( $self, $url ) = @_;
        return if $self->counter( $self->counter + 1 ) > 3;
        if ( $url =~ m{^http://www.bbc.co.uk}ig ) {
            $self->prepend( search => $url ); #  append url on end of list
        }
    }


    sub detail {
        my ( $self ) = @_;
    }

    sub on_finish {
        my ( $self ) = @_;
        $self->robot->writer->save_data( $self->array_of_data );
    }

    1;

=head2 Example 2 - Tabela FIPE ( append custom request calls )

See the working version at: https://github.com/hernan604/WWW-Tabela-Fipe

This example show an asp website that has those '__EVENTVALIDATION' and '__VIEWSTATE' which must be sent back again on each request... here is the example of such a website...

This example also demonstrates how one could easily login into a website and crawl it also.

    package WWW::Tabela::Fipe;
    use Moo;
    with 'HTML::Robot::Scrapper::Reader';
    use Data::Printer;
    use utf8;
    use HTML::Entities;
    use HTTP::Request::Common qw(POST);

    has [ qw/marcas viewstate eventvalidation/ ] => ( is => 'rw' );

    has veiculos => ( is => 'rw' , default => sub { return []; });
    has referer => ( is => 'rw' );

    sub start {
        my ( $self ) = @_;
    }

    has startpage => (
        is => 'rw',
        default => sub {
            return [
              {
                tipo => 'moto',
                url => 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?azxp=1&v=m&p=52'
              },
              {
                tipo => 'carro',
                url => 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?p=51'
              },
              {
                tipo => 'caminhao',
                url => 'http://www.fipe.org.br/web/indices/veiculos/default.aspx?v=c&p=53'
              },
            ]
        },
    );

    sub on_start {
      my ( $self ) = @_;
      foreach my $item ( @{ $self->startpage } ) {
        $self->append( search => $item->{ url }, {
            passed_key_values => {
                tipo => $item->{ tipo },
                referer => $item->{ url },
            }
        } );
      }
    }

    sub _headers {
        my ( $self , $url, $form ) = @_;
        return {
          'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Encoding' => 'gzip, deflate',
          'Accept-Language' => 'en-US,en;q=0.5',
          'Cache-Control' => 'no-cache',
          'Connection' => 'keep-alive',
          'Content-Length' => length( POST('url...', [], Content => $form)->content ),
          'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8',
          'DNT' => '1',
          'Host' => 'www.fipe.org.br',
          'Pragma' => 'no-cache',
          'Referer' => $url,
          'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:20.0) Gecko/20100101 Firefox/20.0',
          'X-MicrosoftAjax' => 'Delta=true',
        };
    }

    sub _form {
        my ( $self, $args ) = @_;
        return [
          ScriptManager1 => $args->{ script_manager },
          __ASYNCPOST => 'true',
          __EVENTARGUMENT => '',
          __EVENTTARGET => $args->{ event_target },
          __EVENTVALIDATION => $args->{ event_validation },
          __LASTFOCUS => '',
          __VIEWSTATE => $args->{ viewstate },
          ddlAnoValor => ( !exists $args->{ano} ) ? 0 : $args->{ ano },
          ddlMarca => ( !exists $args->{marca} ) ? 0 : $args->{ marca },
          ddlModelo => ( !exists $args->{modelo} ) ? 0 : $args->{ modelo },
          ddlTabelaReferencia => 154,
          txtCodFipe => '',
        ];
    }

    sub search {
      my ( $self ) = @_;
      my $marcas = $self->tree->findnodes( '//select[@name="ddlMarca"]/option' );
      my $viewstate = $self->tree->findnodes( '//form[@id="form1"]//input[@id="__VIEWSTATE"]' )->get_node->attr('value');
      my $event_validation = $self->tree->findnodes( '//form[@id="form1"]//input[@id="__EVENTVALIDATION"]' )->get_node->attr('value');
      foreach my $marca ( $marcas->get_nodelist ) {
        my $form = $self->_form( {
            script_manager => 'UdtMarca|ddlMarca',
            event_target => 'ddlMarca',
            event_validation=> $event_validation,
            viewstate => $viewstate,
            marca => $marca->attr( 'value' ),
        } );
        $self->prepend( busca_marca => 'url' , {
          passed_key_values => {
              marca => $marca->as_text,
              marca_id => $marca->attr( 'value' ),
              tipo => $self->robot->reader->passed_key_values->{ tipo },
              referer => $self->robot->reader->passed_key_values->{referer },
          },
          request => [
            'POST',
            $self->robot->reader->passed_key_values->{ referer },
            {
              headers => $self->_headers( $self->robot->reader->passed_key_values->{ referer } , $form ),
              content => POST('url...', [], Content => $form)->content,
            }
          ]
        } );
      }
    }

    sub busca_marca {
      my ( $self ) = @_;
      my ( $captura1, $viewstate ) = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.+)__VIEWSTATE\|([^\|]+)\|/g;
      my ( $captura_1, $event_validation ) = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.+)__EVENTVALIDATION\|([^\|]+)\|/g;
      my $modelos = $self->tree->findnodes( '//select[@name="ddlModelo"]/option' );
      foreach my $modelo ( $modelos->get_nodelist ) {


        next unless $modelo->as_text !~ m/selecione/ig;
        my $kv={};
        $kv->{ modelo_id } = $modelo->attr( 'value' );
        $kv->{ modelo } = $modelo->as_text;
        $kv->{ marca_id } = $self->robot->reader->passed_key_values->{ marca_id };
        $kv->{ marca } = $self->robot->reader->passed_key_values->{ marca };
        $kv->{ tipo } = $self->robot->reader->passed_key_values->{ tipo };
        $kv->{ referer } = $self->robot->reader->passed_key_values->{ referer };
        my $form = $self->_form( {
            script_manager => 'updModelo|ddlModelo',
            event_target => 'ddlModelo',
            event_validation=> $event_validation,
            viewstate => $viewstate,
            marca => $kv->{ marca_id },
            modelo => $kv->{ modelo_id },
        } );
        $self->prepend( busca_modelo => '', {
          passed_key_values => $kv,
          request => [
            'POST',
            $self->robot->reader->passed_key_values->{ referer },
            {
              headers => $self->_headers( $self->robot->reader->passed_key_values->{ referer } , $form ),
              content => POST( 'url...', [], Content => $form )->content,
            }
          ]
        } );
      }
    }

    sub busca_modelo {
      my ( $self ) = @_;
      my $anos = $self->tree->findnodes( '//select[@name="ddlAnoValor"]/option' );
      foreach my $ano ( $anos->get_nodelist ) {
        my $kv = {};
        $kv->{ ano_id } = $ano->attr( 'value' );
        $kv->{ ano } = $ano->as_text;
        $kv->{ modelo_id } = $self->robot->reader->passed_key_values->{ modelo_id };
        $kv->{ modelo } = $self->robot->reader->passed_key_values->{ modelo };
        $kv->{ marca_id } = $self->robot->reader->passed_key_values->{ marca_id };
        $kv->{ marca } = $self->robot->reader->passed_key_values->{ marca };
        $kv->{ tipo } = $self->robot->reader->passed_key_values->{ tipo };
        $kv->{ referer } = $self->robot->reader->passed_key_values->{ referer };
        next unless $ano->as_text !~ m/selecione/ig;

        my ( $captura1, $viewstate ) = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.*)__VIEWSTATE\|([^\|]+)\|/g;
        my ( $captura_1, $event_validation ) = $self->robot->useragent->content =~ m/hiddenField\|__EVENTTARGET(.*)__EVENTVALIDATION\|([^\|]+)\|/g;
        my $form = $self->_form( {
            script_manager => 'updAnoValor|ddlAnoValor',
            event_target => 'ddlAnoValor',
            event_validation=> $event_validation,
            viewstate => $viewstate,
            marca => $kv->{ marca_id },
            modelo => $kv->{ modelo_id },
            ano => $kv->{ ano_id },
        } );

        $self->prepend( busca_ano => '', {
          passed_key_values => $kv,
          request => [
            'POST',
            $self->robot->reader->passed_key_values->{ referer },
            {
              headers => $self->_headers( $self->robot->reader->passed_key_values->{ referer } , $form ),
              content => POST( 'url...', [], Content => $form )->content,
            }
          ]
        } );
      }
    }

    sub busca_ano {
      my ( $self ) = @_;
      my $item = {};
      $item->{ mes_referencia } = $self->tree->findvalue('//span[@id="lblReferencia"]') ;
      $item->{ cod_fipe } = $self->tree->findvalue('//span[@id="lblCodFipe"]');
      $item->{ marca } = $self->tree->findvalue('//span[@id="lblMarca"]');
      $item->{ modelo } = $self->tree->findvalue('//span[@id="lblModelo"]');
      $item->{ ano } = $self->tree->findvalue('//span[@id="lblAnoModelo"]');
      $item->{ preco } = $self->tree->findvalue('//span[@id="lblValor"]');
      $item->{ data } = $self->tree->findvalue('//span[@id="lblData"]');
      $item->{ tipo } = $self->robot->reader->passed_key_values->{ tipo } ;
      warn p $item;

      push( @{$self->veiculos}, $item );
    }

    sub on_link {
        my ( $self, $url ) = @_;
    }

    sub on_finish {
        my ( $self ) = @_;
        warn "Terminou.... exportando dados.........";
        $self->robot->writer->write( $self->veiculos );
    }

=head1 DESCRIPTION

=head1 AUTHOR

    Hernan Lopes
    CPAN ID: HERNAN
    perldelux / movimentoperl
    hernan@cpan.org
    http://github.com/hernan604

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

