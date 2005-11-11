package Sledge::Plugin::Validator;

use strict;
use vars qw($VERSION);
$VERSION = '0.13';

use Carp;
use vars qw($AUTOLOAD);
use UNIVERSAL::require;

sub import {

	my $class = shift;
	my $pkg = caller;

	no strict 'refs';
	*{"$pkg\::valid"} = sub {my $self = shift; return $self->{valid}};

	$pkg->register_hook(
		BEFORE_DISPATCH => sub {
			my $self = shift;

			my $page = $self->{page};
			my $vali_page     = "valid_$page";
			unless($self->can($vali_page)) {
				return;
			}

			#
			# チェック定義メソッドを呼ぶ
			#
			$self->{valid} = Sledge::Plugin::Validator->new(
				LOAD_FUNCTION => [qw(default japanese)],
			);

			$self->$vali_page();

			#
			# 入力チェック
			#
			for my $p ($self->valid->check()) {
				for my $func_array ($self->valid->check($p)) {
					my @args  =  @$func_array;
					my $func  = shift @args;
					my $value = $self->r->param($p);

					#
					# 引数の生成
					#
					for my $args (@args) {
						if (defined $self->r->param($args)) {
							$args = $self->r->param($args);
						}
					}

					#
					# NULL
					#
					if ($func ne "NOT_NULL" and $value eq "") {
						next;
					}

					#
					# 入力チェック
					#
					my $function = $self->valid->{LOADED}->{$func};

					unless (&$function($value, @args) ){
						$self->valid->set_error($func => $p);
					}
				}
			}


			#
			# 入力エラーだった場合
			#
			if ($self->valid->is_error) {

				my $tmpl = $self->valid->err_template();

				$self->load_template($tmpl);
				$self->tmpl->param(valid => $self->valid);

				$self->output_content();
				# *{"$pkg\::dispatch_$page"}      = sub {};
				# *{"$pkg\::post_dispatch_$page"} = sub {};
			}
		},
	);
}


# -------------------------------------------------------------------------
# err_template
#
# -------------------------------------------------------------------------
sub err_template {
	my $self = shift;
	my $tmpl = shift;

	$self->{err_template} = $tmpl if(defined $tmpl);

	return $self->{err_template};
}


# -------------------------------------------------------------------------
# new
#
# -------------------------------------------------------------------------
sub new {
	my $class = shift;
	my %option = @_;

	my $self = bless {PLAN => {}, ERROR => {}, LOADED => {}}, $class;
	
	if (defined $option{LOAD_FUNCTION}) {
		$self->load_function($_) for (@{$option{LOAD_FUNCTION}});
	}

	return $self;
}
sub DESTROY {}

# -------------------------------------------------------------------------
# チェックの定義
#
# -------------------------------------------------------------------------
sub check {
	my $self = shift;

	if (@_ == 0) {
		return keys %{$self->{PLAN}};
	}
	elsif (@_ == 1) {
		return @{$self->{PLAN}->{$_[0]}};
	}
	else {
		$self->_check_set(@_);
	}
}

sub _check_set {
	my $self = shift;
	my (%plan) = @_;
	while (my ($key, $value) = each %plan) {

		# 初期化
		$self->{PLAN}->{$key} = [] if (ref $self->{PLAN}->{$key} ne "ARRAY");

		for my $v (@$value) {
			$v = [$v] if (ref $v ne 'ARRAY');
			my $func = uc shift @$v;

			$self->load_function($func) if (!exists $self->{LOADED}->{$func});
			push(@{$self->{PLAN}->{$key}}, [$func, @$v]);
		}
	}
}

# -------------------------------------------------------------------------
# チェック関数の準備
#
# -------------------------------------------------------------------------
sub set_function {
	my $self = shift;
	my (%func) = @_;

	while (my ($key, $value) = each %func) {
		 $self->{LOADED}->{$key} = $value;
	}
}

sub load_function {
	my $self = shift;
	my $load_function = shift;

	my $module;
	if ($load_function =~ /::/) {
		# ユーザ定義
		$module = $load_function;
	}
	else {
		# Sledge::Plugin::Validator::*
		$module = join "::", ref($self) , lc $load_function;
	}

	$module->require or croak "Can't locate $module";

	#
	# チェック関数のロード
	#
	my $load = $module . "::load";
	$self->$load();
}


# -------------------------------------------------------------------------
# エラーをセット
#
# -------------------------------------------------------------------------
sub set_error {
	my $self = shift;
	my ($error_code, @param_name) = @_;

	for my $p (@param_name) {
		$self->{ERROR}->{$p}->{$error_code} = 1;
	}
}

# -------------------------------------------------------------------------
# エラーのエイリアスのセット
#
# -------------------------------------------------------------------------
sub set_alias {
	my $self  = shift;
	my (%alias) = @_;

	while (my ($alias, $key_ref) = each %alias) {
		$self->{ALIAS}->{$alias} = $key_ref;
	}
}

# -------------------------------------------------------------------------
# エラーかどうかの判断
#
# -------------------------------------------------------------------------
sub is_error {
	my $self  = shift;
	my ($key, $code) = @_;

	return 0 if (scalar(keys %{$self->{ERROR}}) == 0);

	if (@_ == 0) {
		return 1;
	}	

	elsif (@_ == 1) {
		if (exists $self->{ALIAS}->{$key}) {
			for my $alias (@{$self->{ALIAS}->{$key}}) {
				if (exists $self->{ERROR}->{$alias}){
					return 1 if (scalar(keys %{$self->{ERROR}->{$alias}}) >= 1);
				}
			}
		}
		elsif (exists $self->{ERROR}->{$key}){
			return 1 if (scalar(keys %{$self->{ERROR}->{$key}}) >= 1);
		}
	}
	elsif (@_ == 2) {
		if (exists $self->{ALIAS}->{$key}) {
			for my $alias (@{$self->{ALIAS}->{$key}}) {
				if (exists $self->{ERROR}->{$alias}->{$code}){
					return 1;
				}
			}
		}
		elsif (exists $self->{ERROR}->{$key}->{$code}){
			return 1;
		}
	}

	return 0;
}

# -------------------------------------------------------------------------
# $valid->is_FUNCTION で読み込まれているチェックを読むことができる
#
# -------------------------------------------------------------------------
sub AUTOLOAD {
	my $self = shift;

	my $func = $AUTOLOAD;
	   $func =~  s/^.*::is_//;

	$self->load_function($func) if (!exists $self->{LOADED}->{$func});

	if (ref $self->{LOADED}->{$func} eq "CODE") {
		my $function = $self->{LOADED}->{$func};
		return &$function(@_);
	}
	croak qq{Can't load function "$func"};
}

1;
__END__

=head1 NAME

Sledge::Plugin::Validator - FORM から入力されたパラメータチェック。

=head1 SYNOPSIS

  package Project::Pages::Foo;
  use Sledge::Plugin::Validator;

  sub dispatch_foo1 {
      #
      # 入力フォームの表示
      # action="foo2.cgi"
      #
  }

  sub valid_foo2 {

      # エラー時のテンプレートの定義
      $self->valid->err_template('foo1');

      # foo1 のテンプレートの入力チェック
      $self->valid->check(
          login_id  => [qw(INT)],
          name      => [qw(NOT_NULL)],
          kana      => [qw(NOT_NULL KATAKANA)],
          email1    => [qw(NOT_NULL EMAIL),['DUPLICATION', 'email2']],
          email2    => [qw(NOT_NULL EMAIL),['DUPLICATION', 'email1']],
          sex       => [qw(NOT_NULL)],
          type      => [qw(NOT_NULL)],
          age       => [qw(INT), ['LENGTH',1,2]],
          zip1      => [qw(INT), ['LENGTH',3]],
          zip2      => [qw(INT), ['LENGTH',4]],
          tel       => [qw(TEL)],
          fax       => [qw(TEL)],
      );

      # 特定の項目だけチェックを追加したい
      if ($self->r->param('type') eq 'B') {
          $self->valid->check(
              company_name   => [qw(NOT_NULL)],
              company_kana   => [qw(NOT_NULL KATAKANA)],
          );
      }

      # login_id について特殊なチェック(DBを見るとか)
      if ( ..... エラーだったら真になるようなif文など ..... ) {
          $self->valid->set_error('DB', 'login_id');
      }

      # zip1 と zip2 は zip というエラーコードでも判定できるようにする。
      $self->valid->set_alias(
          zip  => [qw(zip1 zip2)]
      );

      # 自作の入力エラー関数を設定
      $self->valid->set_function(
          A_OR_B => sub {return ($_[0] =~ /^[AB]$/)? 1 : 0;}
      );

      # 自作の入力エラー関数群をロード(1)
      #
      # ex. Project/Validator/foo.pm を読み込む
      # 自作関数の作り方は Sledge::Plugin::Validator::default を参考のこと
      $self->valid->load_function("Project::Validator::foo");
      $self->valid->check(
          foo  => [qw(FOO)],
          bar  => [qw(BAR)],
      );

      # 自作の入力エラー関数群をロード(2)
      # Sledge::Plugin::Validator::bar を自動的に読み込みます。
      $self->valid->check(
          bar  => [qw(BAR)],
      );
  }

  #
  # テンプレートでは以下のようにエラーの項目によって適宜メッセージを
  # 生成してください。
  #
  [% IF valid.is_error %]
  入力エラーです。
  <ul>
      [% IF valid.is_error('login_id') %]
          <li>ログインIDを再度入力してください。</li>
      [% END %]
      [% IF valid.is_error('login_id', 'INT') %]
          <li>ログインIDは数字で入力してください。</li>
      [% END %]
      [% IF valid.is_error('login_id', 'DB') %]
          <li>ログインIDは使用できません。</li>
      [% END %]
      :
      :
  </ul>
  [% END %]

=head1 DESCRIPTION

Sledge::Plugin::Validator  FORM から入力されたパラメータチェックする
プラグインです。

L<Sledge::Plugin::Regular>など文字列の正規化を行っている場合は
valid_page が起動されるタイミング(BEFORE_DISPATCH)に注意してください。

入力エラーが起きると post_dispatch, diapatch は実行されずに、設定
しているエラー用のテンプレートを出力します。

未入力は明示的に NOT_xxx を設定していないと
入力チェックが通ります。

=head1 CHECK FUNCTION

check メソッドで定義できるチェックの種類については、
Sledge::Plugin::Validator::*
をごらんになってください。

LENGTH, DATE など引数を必要とするチェックは配列のリファレンス
として渡します。

引数は始めに $self->r->param() に存在するかどうかをチェックし、値がある場合は
その値に変換されます。

=head1 METHOD

いずれも、Sledgeオブジェクトとしてではなく、valid オブジェクトから使用します。

=over 4

=item new

オブジェクトを作成します。
BEFORE_DISPATCH のタイミングで自動的に実行されます。
普段は気にする必要はありません。

=item err_template

エラー時に出力するテンプレートを設定します。

=item check

チェック定義を追加します。

  $self->valid->check( 'name' => ['NOT_NULL']

=item  set_function

入力チェック関数を定義します。

  # 入力値が FOO でなかったらエラーになる定義
  $self->valid->set_function(
      FOO => sub { return ($_[0] eq "FOO")? 1 : 0} 
  );

=item  load_function

ファイルから、入力チェック関数を読み込みます。
入力チェック関数の作り方は L<Sledge::Plugin::Validator::default> を参考に
してください。

=item  set_error

自分で入力チェックなどしたときに、エラーをセットします。

  $self->valid->set_error('DB', 'login_id');

=item  set_alias

エラーの別名を定義します。
以下のコードを書くと zip1 や zip2 でエラーになったとき
is_error メソッドで zip もエラーになります。

  $self->valid->set_alias(
      zip  => [qw(zip1 zip2)]
  );

=item  is_error

エラーかどうかの真偽値が返ります。
普段はテンプレート内でしか使用しません。

  [% IF valid.is_error %]
     全体で一つでもエラーがあれば真
  [% END %] 

  [% IF valid.is_error('name') %]
     name が 一つでもエラーになっていれば真
  [% END %] 

  [% IF valid.is_error('name', 'NOT_NULL') %]
     name かつ NOT_NULL がエラーになっていれば真
  [% END %] 

=item is_FUNCTION

一度読み込みされていれば(check で定義したり、load_function, load_function
で設定されていれば) is_FUNCTON で入力定義を呼び出すことができます。

  if ($self->valid->is_INT($baz)) {
      $self->valid->set_error('INT', 'baz');
  }

この仕組みは、実験的に導入されています。

=back

=head1 TODO

=over 4

=item エラーメッセージの自動生成

エラーメッセージを生成するのがめんどくさいので、ある程度は自動的に
生成されるようにしたい。

どうするのが、便利かつ綺麗かなぁ？アイディア募集中。

=back

=head1 BUGS

何かバグや要望がありましたら、メールでお問い合わせ
ください。


=head1 AUTHOR

KIMURA, takefumi E<lt>takefumi@takefumi.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Sledge::Plugin::Validator::date>,
L<Sledge::Plugin::Validator::default>,
L<Sledge::Plugin::Validator::email>,
L<Sledge::Plugin::Validator::email_super_loose>,
L<Sledge::Plugin::Validator::email_loose>,
L<Sledge::Plugin::Validator::email_strict>,
L<Sledge::Plugin::Validator::japanese>

=cut
