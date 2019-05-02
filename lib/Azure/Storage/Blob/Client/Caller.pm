package Azure::Storage::Blob::Client::Caller;
use Moose;
use LWP::UserAgent;
use HTTP::Tiny;
use HTTP::Request;
use HTTP::Date;

has user_agent => (
  is => 'ro',
  lazy => 1,
  default => sub { return LWP::UserAgent->new() },
);

sub request {
  my ($self, $call_object) = @_;

  my $request = $self->_prepare_request($call_object);
  return $self->user_agent->request($request);
}

sub _prepare_request {
  my ($self, $call_object) = @_;

  if ($call_object->method ne 'GET') {
    die 'Unimplemented.';
  }

  my $url_encoded_parameters = HTTP::Tiny->new->www_form_urlencode(
    $call_object->serialize_parameters(),
  );
  my $url = sprintf("%s&%s", $call_object->endpoint, $url_encoded_parameters);
  my $request = HTTP::Request->new($call_object->method => $url);

  $self->_set_headers($request, $call_object);

  return $request;
}

sub _set_headers {
  my ($self, $request, $call_object) = @_;

  $request->header('x-ms-version', '2018-03-28');
  $request->header('Date', HTTP::Date::time2str());
}

__PACKAGE__->meta->make_immutable();

1;
