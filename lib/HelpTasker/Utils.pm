package HelpTasker::Utils;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(dumper);
use Mojo::JSON qw(false true);

has api => sub { shift->app->api };

#	$self->app->api->utils->error_validation($validation);


sub error_validation {
	my ($self,$validation) = @_;
	for my $field (@{$validation->failed}){
		my ($check, $result, @args) = @{$validation->error($field)};
		my ($pkg, $line) = (caller())[0, 2];
		($pkg, $line) = (caller(1))[0, 2] if $pkg eq ref $self;
		die qq/invalid param $field, check:$check, package $pkg\[$line\]/;
	}
}

1;
