use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	VERSION   => '0.01',
	PREREQ_PM => {
		'Mojolicious' => '6.14',
		'DBI' => '1.636',
		'DBD::mysql' => '4.033',
	},
	test=>{TESTS => 't/*.t'}
);


