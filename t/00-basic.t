use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw(dumper);
use DBI;

my $t = Test::Mojo->new('Api');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

# Elasticsearch
my $result = $t->get_ok('http://127.0.0.1:9200/_nodes');
ok($result->tx->res->json->{'cluster_name'} eq 'elasticsearch', 'check version');

# Mysql
if(defined $ENV{'MOJO_TEST_TRAVIS'} && $ENV{'MOJO_TEST_TRAVIS'} == 1){
	my $dbh = DBI->connect("DBI:mysql:database=test;host=localhost;port=3306", 'root', undef);
	my $sth = $dbh->prepare("SELECT VERSION() as `version`");
	$sth->execute();
	while (my $ref = $sth->fetchrow_hashref()) {
		die $ref->{'version'};
	}
	$sth->finish();
	$dbh->disconnect();
}


done_testing();
