use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	VERSION   => '0.01',
	PREREQ_PM => {
		'Mojolicious' => '6.14',
		'MojoX::Mysql' => '0.21',
		'Minion' => '5.06',
	},
	test=>{TESTS => 't/*.t'}
);


