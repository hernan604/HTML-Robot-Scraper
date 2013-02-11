# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More;
use HTML::Robot::Scrapper;
BEGIN { use_ok( 'HTML::Robot::Scrapper', 'use is fine' ); }

my $robot = HTML::Robot::Scrapper->new (
    reader    => {                                                       # REQ
        class => 'HTML::Robot::Scrapper::Reader::TestReader',
#       args  => { #will be passed to ->new(here) in class^^
#         argument1 => 'xx'
#       },
    },
    writer    => {class => 'HTML::Robot::Scrapper::Writer::TestWriter',}, #REQ
    benchmark => {class => 'Default'},
    cache     => {class => 'Default'},
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
