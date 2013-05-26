# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More;
use HTML::Robot::Scrapper;
use File::Path qw|make_path remove_tree|;
use CHI;
use Cwd;
use Path::Class;
BEGIN { use_ok( 'HTML::Robot::Scrapper', 'use is fine' ); }

sub create_cache_dir {
  my $dir  = dir(getcwd(), 'cache'); 
  make_path( $dir, 'cache' );
}
&create_cache_dir;

my $robot = HTML::Robot::Scrapper->new (
    reader    => {                                                       # REQ
        class => 'HTML::Robot::Scrapper::Reader::TestReader',
#       class => 'HTML::Robot::Scrapper::Reader::Lopes',
#       args  => { #will be passed to ->new(here) in class^^
#         argument1 => 'xx'
#       },
    },
    writer    => {class => 'HTML::Robot::Scrapper::Writer::TestWriter',}, #REQ
    benchmark => {class => 'Default'},
    cache     => {
        class => 'Default',
        args  => {
            is_active => 0,
            engine => CHI->new(
                    driver => 'BerkeleyDB',
                    root_dir => "/home/catalyst/HTML-Robot-Scraper/cache/",
            ),
        },
    },
    log       => {class => 'Default'},
    parser    => {class => 'Default'},
    queue     => {class => 'Default'},
    useragent => {class => 'Default'},
    encoding  => {class => 'Default'},
    instance  => {class => 'Default'},
);
isa_ok ($robot, 'HTML::Robot::Scrapper', 'is obj scrapper');

$robot->start();

done_testing();
