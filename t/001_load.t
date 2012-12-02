# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'HTML::Robot::Scraper' ); }

#my $object = HTML::Robot::Scraper->new ();


my $robot = HTML::Robot::Scraper->new( {
  instructions => {
      read  => 'HTML::Robot::Scraper::Reader::BBC', #What to do with web pages, read  data
      write => 'HTML::Robot::Scraper::Writer::Data' #How to save web page data, write data
  },
  local_cache => {
      enabled => 1,                               #save pages localy, good when developing/offline testing
      directory => '/home/catalyst/HTML-Robot-Scraper/cache/',
  },
  before_normalize_url => { #OPTIONAL. Use to skip urls
      is_active => 1,
      code => sub {
          my ( $url ) = @_;
          return undef if $url =~ m/^#/gi;
          $url =~ s/([^#]+)#(.+)/$1/g;
          return $url;
      }
  },
  images => {
      enabled => 1,
      content_type => [
        qw|
image/gif
image/jpeg
image/pjpeg
image/png
        |
      ],
      directory => '/home/images',
  },
  engines => {
      queue => 'HTML::Robot::Scraper::Engine::Queue::Array', # Array|Redis
      user_agent => 'HTML::Robot::Scraper::Engine::UserAgent::HTTP::Tiny',
  },
  parsers => {
      process => {
          'text/html' => {                        #processa content type com modulos
              with_class => 'HTML::Robot::Scraper::Parser::HTML::TreeBuilder::XPath',
              use_method => 'parse_xpath', #method within class^^ that will receive content and parse
          },
          'text/xml' => {
              with_class => 'HTML::Robot::Scraper::Parser::XML::XPath',
              use_method => 'parse_xml', #method inside that class that will receive content and parse
          },
      }
  },
} );

isa_ok ($robot, 'HTML::Robot::Scraper');
