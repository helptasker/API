package Api;
use Mojo::Base 'Mojolicious';
use Mojo::Util qw(dumper);
use Mojo::JSON qw(false true);
use Try::Tiny;

use HelpTasker::Base;


# This method will run once at server start
sub startup {
	my $self = shift;

	$self->moniker('helptasker_api');
	$self->secrets(['DSASDASDASDASDCVCXVZCVZFGSFGSDFGSHRTEYETYDGGJFKUI']);
	$self->sessions->cookie_name($self->moniker);
	$self->sessions->default_expiration(3600);

	# Выставляем правильные charset для content-type
	$self->app->types->type(txt=>'text/plain; charset=utf-8');
	$self->app->types->type(html=>'text/html; charset=utf-8');
	$self->app->types->type(xml=>'text/xml; charset=utf-8');
	$self->app->types->type(json=>'application/json; charset=utf-8');

	# Path template files
	shift @{$self->app->renderer->paths};
	push( @{$self->app->renderer->paths}, $self->app->home->rel_dir('templates').'/'.$self->moniker);

	# Path static files
	shift @{$self->static->paths};
	push( @{$self->static->paths}, $self->app->home->rel_dir('public').'/'.$self->moniker);

	# Setup Mojo::UserAgent
	$self->app->ua->on(start=>sub{
		my ($ua, $tx) = @_;
		$tx->req->headers->header('User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/41.0.2272.76 Chrome/41.0.2272.76 Safari/537.36');
		$tx->req->headers->header('Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8');
		$tx->req->headers->header('Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4');
	});
	$self->app->ua->connect_timeout(5);     # Connect timeout
	$self->app->ua->inactivity_timeout(15); # Inactivity timeout
	$self->app->ua->request_timeout(15);    # Request timeout

	$self->app->helper('api' => sub{ HelpTasker::Base->new(app=>$self->app) });

	# hook
	$self->hook(around_dispatch=>sub {
		my ($next, $c) = @_;

		# Costom error json
		try {
			$next->();
		}
		catch {
			my $exception = $_;
			my $message = $exception->message;
			chomp $message;
			$self->app->log->fatal($message);

			my $json = {error=>$message};

			# Chain frames
			for my $item (@{$exception->frames}){
				push(@{$json->{'trace'}}, {module=>$item->[0], file=>$item->[1], line=>$item->[2]});
			}

			# Logging
			for my $item (@{$c->app->log->history}){
				push(@{$json->{'log'}}, {date=>Mojo::Date->new($item->[0]), level=>$item->[1], message=>$item->[2]});
			}

			# Code
			for my $item (@{$exception->lines_before}){
				push(@{$json->{'code'}}, {line=>$item->[0], string=>$item->[1], selected=>$self->false});
			}

			push(@{$json->{'code'}}, {line=>$exception->line->[0], string=>$exception->line->[1], selected=>$self->true});

			for my $item (@{$exception->lines_after}){
				push(@{$json->{'code'}}, {line=>$item->[0], string=>$item->[1], selected=>$self->false});
			}

			if(defined $ENV{'MOJO_TEST'}){
				delete $json->{'code'};
				delete $json->{'log'};
				delete $json->{'trace'};
			}

			$c->render(json=>$json, status=>500);
			return;
		};
		return;
	});

	$self->plugin('PODRenderer');

	my $r = $self->routes;

	#my $api_route = $r->under('/v1');
	$r->any(['GET','POST'] =>'/v1/testing/types')->to(namespace=>'HelpTasker', controller=>'Testing', action=>'types');
	$r->any(['GET','POST'] =>'/v1/testing/die')->to(namespace=>'HelpTasker', controller=>'Testing', action=>'test_die');
	$r->any(['GET','POST'] =>'/v1/testing/params')->to(namespace=>'HelpTasker', controller=>'Testing', action=>'params');
	$r->any(['GET','POST'] =>'/v1/testing/sub_params')->to(namespace=>'HelpTasker', controller=>'Testing', action=>'sub_params');


	#$r->any('/v1/*')->to(cb=>sub{
	#	my $c = shift;
	#	if($c->req->url->path =~ m/\/v(?<version>([0-9]+))\/(?<method>([0-9a-z\_\-\.]+))/i){
	#		my $version = $+{'version'};
	#		my $call    = $+{'call'};
	#		my $method  = $c->req->method;
	#		$method = lc($method);

	#		my $object = $self->api->testing;

	#		my $json = {};
	#		if($method eq 'get'){
	#			$json = $object->list->result;
	#		}
	#		elsif($method eq 'post'){
	#			$json = $object->update->result;
	#		}
	#		elsif($method eq 'put'){
	#			$json = $object->create->result;
	#		}
	#		elsif($method eq 'delete'){
	#			$json = $object->remove->result;
	#		}

			#my $object = $self->api->testing->types->result;

			#say "$version $method";
	#		$c->render(json=>1);
	#		return;
	#	}

	#	$c->render(json=>'Good bye.');
	#});


	#my $api = $r->under(sub {
	#	my $c = shift;
	#	return undef;
	#});




	#$self->api->testing->get_route($r);


	#$r->get('/tickets/:ticket_id'=> [ticket_id => qr/[0-9;]+/])->to(cb=>sub{
	#	my $c = shift;
	#	$c->render(json=>$c->api->testing->echo->result);
	#});
}

1;
