package # Hide from PAUSE
  StompTestApp::Controller::DisabledController;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::MessageDriven' };

has stomp_destination => (
    is => 'ro',
    isa => 'Str',
    default => '/queue/test_disabled',
);

sub testaction : Local {
    my ($self, $c, $request) = @_;

    my $response = {
        from => 'disabled',
    };
    $c->stash->{response} = $response;
    $c->response->headers->header(type => 'disabled_response');
}

1;
