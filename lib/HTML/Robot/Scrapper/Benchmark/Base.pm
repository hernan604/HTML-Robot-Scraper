package HTML::Robot::Scrapper::Benchmark::Base;
use Moose;
use Data::Printer;
#TODO: add proper stacktrace 
#or some structure ie: This way its possible to iterate over the structure and get overall time for each method call
# my $command_tree = {
#   time => 99999111,
#   commands => [
#     cmd1 => {
#       time => 222,
#       commands => [],
#     },
#     cmd2 => {
#       time => 333,
#       commands => [
#         cmd3 => {
#           time => 333,
#           commands => [],
#         },
#         cmd4 => {
#           time => 222,
#           commands => [
#             cmd6 => {
#               time => 111.1,
#               commands => [],
#             },
#             cmd7 => {
#               time => 111.2,
#               commands => [],
#             },
#             cmd8 => {
#               time => 111.3,
#               commands => [],
#             },
#           ]
#         },
#         cmd5 => {
#           time => 111,
#           commands => [],
#         },
#       ]
#     },
#   ]
# };

has robot => ( is => 'rw', );
has engine => ( is => 'rw', );

has values => ( is => 'rw' );

sub method_start  {
    my ( $self ) = shift; 
    return $self->engine->method_start( @_ );
}

sub method_finish  {
    my ( $self ) = shift; 
    return $self->engine->method_finish( @_ );
}

1;
