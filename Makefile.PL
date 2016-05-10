use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	VERSION   => '0.01',
	PREREQ_PM => {
		'Mojolicious' => '6.14'
		'DBI' => 0,
		'DBD::mysql' => 0,
	},
	test=>{TESTS => 't/*.t'}
);


