use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw(dumper);
use DBI;

my $t = Test::Mojo->new('Api');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

# Elasticsearch
my $result = $t->get_ok('http://127.0.0.1:9200/_nodes');
ok($result->tx->res->json->{'cluster_name'} eq 'elasticsearch', 'check elasticsearch');

# Mysql travis vesion
if(defined $ENV{'MOJO_TEST_TRAVIS'} && $ENV{'MOJO_TEST_TRAVIS'} == 1){
	my $dbh = DBI->connect("DBI:mysql:database=test;host=127.0.0.1;port=3306", 'root', 'test');
	my $sth = $dbh->prepare("SELECT VERSION() as `version`");
	$sth->execute();
	while (my $ref = $sth->fetchrow_hashref()) {
		my $version = $ref->{'version'};
		like($version,qr/^5\.7\.[0-9]+/,'check mysql version =< 5.7');
	}
	$sth->finish();
	$dbh->disconnect();
}

done_testing();
