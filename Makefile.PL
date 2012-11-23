

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'HTML::Robot::Scraper',
    VERSION_FROM => 'lib/HTML/Robot/Scraper.pm', # finds \$VERSION
    AUTHOR       => 'Hernan Lopes (hernanlopes@gmail.com)',
    ABSTRACT     => 'Your robot to parse webpages',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
