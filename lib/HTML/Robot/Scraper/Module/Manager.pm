package HTML::Robot::Scraper::Module::Manager;
use Moose::Role;


before 'load_modules' => sub {
    my ( $self ) = @_;
#   $self->validate_modules();
    warn "\n *** TODO: Validar modulos";
    #is defined $self->instructions->{read}
    #etc
};

sub load_modules {
    my ( $self ) = @_;
    warn "*** load_modules ***";
    Class::MOP::load_class( $self->instructions->{write} );
    Class::MOP::load_class( $self->instructions->{read} );

    foreach my $content_type ( keys $self->parsers->{process} ) {
        Class::MOP::load_class( $self->parsers->{process}->{$content_type}->{with_class} );
        Moose::Util::apply_all_roles( $self, ( $self->parsers->{process}->{$content_type}->{with_class} ) );

        $self->parser_methods->{ $self->parsers->{process}->{$content_type}->{with_class} } =
          $self->parsers->{process}->{$content_type}->{use_method};

        $self->parser_content_type->{ $content_type } =
          $self->parsers->{process}->{$content_type}->{with_class};
    }
    Moose::Util::apply_all_roles( $self, ($self->instructions->{read}) ); ## carrega Reader como Role
    $self->writer( $self->instructions->{write}->new() );
use Data::Printer; warn p $self->writer;
}

1;
