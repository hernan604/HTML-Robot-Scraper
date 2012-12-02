package HTML::Robot::Scraper;
use Moose;
use URI;
use Data::Printer;
#use lib './';
with qw/
HTML::Robot::Scraper::Module::Manager
HTML::Robot::Scraper::EngineUserAgent
HTML::Robot::Scraper::EngineQueue
HTML::Robot::Scraper::Encoding
/;

our $VERSION     = '0.01';

has [ qw/response instructions local_cache images engines parsers writer reader current_page current_status html_content before_normalize_url/ ] => (
  is => 'rw',
  isa => 'Any',
);

has parser_methods => (
    is => 'rw',
    isa => 'Any',
    default => sub { {} } ,
);
has parser_content_type => (
    is => 'rw',
    isa => 'Any',
    default => sub { {} } ,
);

#array queue
has url_list => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { return []; },
);
has url_list_hash => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { return {}; },
);
has url_visited => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);


sub BUILD {
    my ( $self ) = @_;
    $self->load_modules();
}

after 'BUILD' => sub {
    my ( $self ) = @_;
    $self->start( $self );
    $self->on_start( $self );
    while ( my $item = $self->queue_get_item ) {
        $self->visit($item);
    }
    $self->on_finish( $self );
};

sub normalize_url {
    my ( $self, $url ) = @_;
    if (       ref $self->before_normalize_url eq ref {}
        and exists $self->before_normalize_url->{is_active}
               and $self->before_normalize_url->{is_active} == 1
        and exists $self->before_normalize_url->{code}
        ) {
        $url = $self->before_normalize_url->{code}->( $url );
    }
    if ( defined $url ) {
        $self->current_page( $url ) if ! defined $self->current_page;
        my     $final_url = URI->new_abs( $url , $self->current_page );
        return $final_url->as_string();
    }
}

































=head1 NAME

HTML::Robot::Scraper - Your robot to parse webpages

=head1 SYNOPSIS

  use HTML::Robot::Scraper;
  my $robot = HTML::Robot::Scraper->new( {
    instructions => {
        read  => 'HTML::Robot::Scraper::Reader::BBC', #What to do with web pages
        write => 'HTML::Robot::Scraper::Writer::Data'       #How to save web page data
    },
    local_cache => {
        enabled => 1,                               #save pages localy, good when developing/offline testing
        directory => '/home/hernan/perl/HTML-Robot-Scraper/cache/',
    },
    images => {
        directory => '/home/images',
    },
    engines => {
        queue => 'Array', # Array|Redis
        user_agent => 'HTTP::Tiny',
    },
    parsers => {
        preload => [                                #carrega estes modulos
            'Treebuilder::XPath',
            'HTML::Selector'
        ],
        process => {
            'text/html' => [                        #processa content type com modulos
                'Treebuilder::XPath',
                'HTML::Selector'
            ]
        }
    },
  } );


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE



=head1 BUGS



=head1 SUPPORT



=head1 AUTHOR

    Hernan Lopes
    CPAN ID: HERNAN
    Movimento perl
    hernanlopes@gmail.com
    http://github.com/hernan604

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

1;
