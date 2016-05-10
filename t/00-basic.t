use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw(dumper);

my $t = Test::Mojo->new('Api');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

my $t = $t->get_ok('http://127.0.0.1:9200/_nodes');
ok($t->tx->res->json->{'cluster_name'} eq 'elasticsearch', 'check version');

done_testing();