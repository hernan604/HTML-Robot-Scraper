

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'HTML::Robot::Scrapper',
    VERSION_FROM => 'lib/HTML/Robot/Scrapper.pm', # finds \$VERSION
    AUTHOR       => 'Hernan Lopes (hernan@cpan.org)',
    ABSTRACT     => 'Your robot to parse webpages',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'CHI' => 0,
                     'CHI::Driver::BerkeleyDB' => 0,
                    },
);
