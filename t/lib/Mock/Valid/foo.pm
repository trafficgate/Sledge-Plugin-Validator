package Mock::Valid::foo;
use strict;

sub load {
    my $self = shift;

    $self->set_function(
        FOO => sub { return ($_[0] eq 'FOO')? 1 : 0},
    );
}

1;
