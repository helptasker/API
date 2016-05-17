use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw(dumper);
use DBI;

$ENV{'MOJO_TEST'} = 1;

my $t = Test::Mojo->new('Api');

note('types');
$t->get_ok('/v1/testing/types/')->status_is(200);
$t->json_is('/int'=>1234567890);
$t->json_is('/array'=>[1..10]);
$t->json_is('/false'=>0);
$t->json_is('/miscellaneous_symbols/heart'=>"\x{2665}");
$t->json_is('/miscellaneous_symbols/umbrella_with_rain_drops'=>"\x{2614}");
$t->json_is('/string/cyrillic'=>"Кириллица");
$t->json_is('/string/cyrillic'=>"\x{41a}\x{438}\x{440}\x{438}\x{43b}\x{43b}\x{438}\x{446}\x{430}");
$t->json_is('/string/roman_alphabet'=>"Roman Alphabet");

note('die');
$t->get_ok('/v1/testing/die/')->status_is(500);
$t->json_like('/error'=> qr/^example\sdie\sat/,'Example die');

note('param');

my $query = "int=1234567890&miscellaneous_symbols_heart=\x{2665}&miscellaneous_symbols_umbrella_with_rain_drops=\x{2614}&";
$query .= "string_cyrillic=Кириллица&string_roman_alphabet=Roman Alphabet";

$t->get_ok("/v1/testing/params/?$query")->status_is(200);
$t->json_is('/int'=>1234567890);
$t->json_is('/miscellaneous_symbols_heart'=>"\x{2665}");
$t->json_is('/miscellaneous_symbols_umbrella_with_rain_drops'=>"\x{2614}");
$t->json_is('/string_cyrillic'=>'Кириллица');
$t->json_is('/string_roman_alphabet'=>'Roman Alphabet');

#say dumper $t->tx->res->json;

done_testing();
