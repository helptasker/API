package HelpTasker::Base;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(dumper);

use HelpTasker::Testing;
use HelpTasker::Utils;

sub testing { HelpTasker::Testing->new(app=>shift->app) }
sub utils { HelpTasker::Utils->new(app=>shift->app) }


1;
