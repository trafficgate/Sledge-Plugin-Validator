package Sledge::Plugin::Validator::date;
use strict;
use vars qw($VERSION);
$VERSION = '0.03';

sub load {
	my $self = shift;

	$self->set_function(
		DATE => \&is_DATE,
	);
}

sub is_DATE {
	my ($y, $m, $d) = @_;

	if ($d > 31 or $d < 1 or $m > 12 or $m < 1 or $y == 0) {
		return 0;
	}
	if ($d > 30 and ($m == 4 or $m == 6 or $m == 9 or $m == 11)) {
		return 0;
	}
	if ($d > 29 and $m == 2) {
		return 0;
	}
	if ($m == 2 and $d > 28 and !($y % 4 == 0 and ($y % 100 != 0 or $y % 400 == 0))){
		return 0;
	}

	return 1;
}

1;

=head1 NAME

Sledge::Plugin::Validator::date - 日付のチェック

=head1 SYNOPSIS

  $self->valid->load_function('DATE');
  unless ($self->valid->is_DATE(map {$self->r->param($_)} qw(yyyy mm dd))) {
      $self->valid->set_error(qw(DATE yyyy mm dd));
  }

  $self->valid->set_alias(
      date => [qw(yyyy mm dd)]
  );

  # 以下のように書くこともできます。
  $self->valid->check(
	  yyyy => [[qw(DATE mm dd)]]
  );

  $self->valid->set_alias(
      date => [qw(yyyy mm dd)]
  );

=head1 DESCRIPTION

日付が正しいかどうかのチェックを行います。


=head1 CHECK FUNCTION

=over 4

=item DATE

日付が正しいかどうかのチェックを行います。

=back

=head1 TODO

いろいろな形式の日付に対応

=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator>

=cut

