package Api::Controller::Testing;
use Mojo::Base 'Mojolicious::Controller';

sub types {
	my $self = shift;
	return $self->render(json=>$self->api->testing->types(c=>$self)->result);
}

1;
