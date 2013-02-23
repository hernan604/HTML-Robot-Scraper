package HTML::Robot::Scrapper;
use Moo;
use Class::Load ':all';
use Data::Dumper;
use Data::Printer;
use Try::Tiny;

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
            warn "Could not load base_class: " . $base_class;
        };
warn $base_class;

        #load custom engine
        try {
            $engine_class = load_class( $engine_class );
        } catch {
            $engine_class = load_class( $options->{ $option }->{ class } );
        };
warn $engine_class;
warn $option;
        my $args = $options->{$option}->{args}||{};
        $options->{$option} = $base_class->new(
            engine => $engine_class->new( $args ),
        );
    }
    my $reader_class = load_class( $options->{ reader }->{ class } );
    $options->{reader} = $reader_class->new( $options->{ reader }->{ args } || {} );

    my $writer_class = load_class( $options->{ writer }->{ class } );
    $options->{writer} = $writer_class->new( $options->{ writer }->{ args } || {} );

    return $options;
};

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
    while ( my $item = $self->queue->queue_get_item ) {
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

        $self->reader->$method( );
    }
    $self->reader->on_finish( );
}

=head1 NAME

HTML::Robot::Scrapper - Your robot to parse webpages

=head1 SYNOPSIS

  use HTML::Robot::Scrapper;
  blah blah blah


=head1 DESCRIPTION

=head1 AUTHOR

    Hernan Lopes
    CPAN ID: HERNAN
    movimentoperl
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

