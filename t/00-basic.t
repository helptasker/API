use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw(dumper);

my $t = Test::Mojo->new('Api');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

# Elasticsearch
my $result = $t->get_ok('http://127.0.0.1:9200/_nodes');
ok($result->tx->res->json->{'cluster_name'} eq 'elasticsearch', 'check version');

# Mysql
if(defined $ENV{'MOJO_TEST_TRAVIS'} && $ENV{'MOJO_TEST_TRAVIS'} == 1){

}


done_testing();
