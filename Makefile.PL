use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'         => 'Sledge::Plugin::Validator',
	'VERSION_FROM' => 'lib/Sledge/Plugin/Validator.pm', # finds $VERSION
	'PREREQ_PM'    => {
		Test::More => 0.32,
		UNIVERSAL::require  => 0,
		Email::Valid        => 0,
		Email::Valid::Loose => 0,
		Jcode               => 0,
	},
);
