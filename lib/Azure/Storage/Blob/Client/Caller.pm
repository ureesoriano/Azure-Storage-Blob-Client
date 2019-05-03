package Azure::Storage::Blob::Client::Caller;
use Moose;
use LWP::UserAgent;
use HTTP::Tiny;
use HTTP::Request;
use HTTP::Headers;
use HTTP::Date;
use Digest::SHA qw(hmac_sha256_base64);
use MIME::Base64;
use Encode;

use Azure::Storage::Blob::Client::Service::Signer;

has user_agent => (
  is => 'ro',
  lazy => 1,
  default => sub { return LWP::UserAgent->new() },
);

has signer => (
  is => 'ro',
  isa => 'Azure::Storage::Blob::Client::Service::Signer',
  lazy => 1,
  default => sub { Azure::Storage::Blob::Client::Service::Signer->new() },
);

sub request {
  my ($self, $call_object) = @_;

  my $request = $self->_prepare_request($call_object);
  my $response = $self->user_agent->request($request);

  return $call_object->parse_response($response);
}

sub _prepare_request {
  my ($self, $call_object) = @_;

  if (
    $call_object->operation ne 'GetBlobProperties' and
    $call_object->operation ne 'ListBlobs' and
    $call_object->operation ne 'PutBlob'
  ) {
    die 'Unimplemented.';
  }

  my $url_encoded_parameters = HTTP::Tiny->new->www_form_urlencode(
    $call_object->serialize_uri_parameters(),
  );
  my $url = $url_encoded_parameters
    ? sprintf("%s&%s", $call_object->endpoint, $url_encoded_parameters)
    : $call_object->endpoint;

  my $body = $self->_build_body_content($call_object);
  my $headers = $self->_build_headers($call_object, $body);
  my $request = HTTP::Request->new($call_object->method, $url, $headers, $body);
  $self->_sign_request($request, $call_object);

  return $request;
}

sub _build_body_content {
  my ($self, $call_object) = @_;

  return join('',
    values %{ $call_object->serialize_body_parameters() }
  );
}

sub _build_headers {
  my ($self, $call_object, $body) = @_;

  return HTTP::Headers->new(
    'x-ms-version' => '2018-03-28',
    'Date'=> HTTP::Date::time2str(),
    $body ? ('Content-Length' => length(Encode::encode_utf8($body))) : (),
    %{ $call_object->serialize_header_parameters() },
  );
}

sub _sign_request {
  my ($self, $request, $call_object) = @_;
  $request->header('Authorization',
    sprintf(
      "SharedKey %s:%s",
      $call_object->account_name,
      $self->signer->calculate_signature($request, $call_object),
    ),
  );
}

__PACKAGE__->meta->make_immutable();

1;
