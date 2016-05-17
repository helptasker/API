package HelpTasker::Testing;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(dumper);
use Mojo::JSON qw(false true);
#use overload bool => sub {undef}, fallback => 1;

has api => sub { shift->app->api };

sub to_hash { shift->stash('to_hash') };
#sub to_array { shift->stash('to_array') };
#sub to_string { shift->stash('to_string') };

sub types {
	my ($self) = @_;

	my $json = {
		string=>{
			roman_alphabet=>'Roman Alphabet',
			cyrillic=>'Кириллица',
		},
		int=>1234567890,
		array=>[1..10],
		true=>true,
		false=>false,
		miscellaneous_symbols=>{
			heart=>"\x{2665}",
			umbrella_with_rain_drops=>"\x{2614}",
		},
	};

	return $self->render(json=>$json) if($self->stash('action'));
	return $json;
}

sub test_die {
	my ($self) = @_;
	die 'example die';
}

sub params {
	my ($self,%param) = @_;
	my $validation = %param ? $self->app->validation->input(\%param) : $self->validation;
	$validation->required('int')->like(qr/^[0-9]+$/);
	$validation->required('miscellaneous_symbols_heart');
	$validation->required('miscellaneous_symbols_umbrella_with_rain_drops');
	$validation->required('string_cyrillic');
	$validation->required('string_roman_alphabet');

	$self->api->utils->error_validation($validation);

	return $self->render(json=>$validation->output) if($self->stash('action'));
	return $validation->output;
}

sub sub_params {
	my ($self,%param) = @_;
	#my $validation = $self->app->validation;
	#$validation->input(\%param) if(%param);
	#$validation->required('param');
	#$self->api->utils->error_validation($validation);

	$self->api->testing->params(param=>1);

	return $self->render(json=>{}) if($self->stash('action'));
}

1;
