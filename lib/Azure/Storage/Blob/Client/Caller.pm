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

has user_agent => (
  is => 'ro',
  lazy => 1,
  default => sub { return LWP::UserAgent->new() },
);

sub request {
  my ($self, $call_object) = @_;

  my $request = $self->_prepare_request($call_object);
  my $response = $self->user_agent->request($request);

  return $call_object->parse_response($response);
}

sub _prepare_request {
  my ($self, $call_object) = @_;

  if ($call_object->operation ne 'ListBlobs' and $call_object->operation ne 'GetBlobProperties') {
    die 'Unimplemented.';
  }

  my $url_encoded_parameters = HTTP::Tiny->new->www_form_urlencode(
    $call_object->serialize_parameters(),
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
      $self->_calculate_signature($request, $call_object),
    ),
  );
}

# Docs: https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key
sub _calculate_signature {
  my ($self, $request, $call_object) = @_;
  my $signature_string =
    $request->method()                      ."\n".
    $request->header('Content-Encoding')    ."\n".
    $request->header('Content-Language')    ."\n".
    $request->header('Content-Length')      ."\n".
    $request->header('Content-MD5')         ."\n".
    $request->header('Content-Type')        ."\n".
    $request->header('Date')                ."\n".
    $request->header('If-Modified-Since')   ."\n".
    $request->header('If-Math')             ."\n".
    $request->header('If-None-Match')       ."\n".
    $request->header('If-Unmodified-Since') ."\n".
    $request->header('Range')               ."\n".
    $self->_canonicalized_headers_string($request).
    $self->_canonicalized_resource_string($request, $call_object);

  my $signature = Digest::SHA::hmac_sha256_base64(
    $signature_string,
    MIME::Base64::decode_base64($call_object->account_key),
  );

  return "$signature=";
}

sub _canonicalized_headers_string {
  my ($self, $request) = @_;

  return join("",
    map { sprintf("%s:%s\n", lc($_), $request->header($_)) }
    sort
    grep { $_ =~ /^x-ms/i }
    $request->header_field_names()
  );
}

sub _canonicalized_resource_string {
  my ($self, $request, $call_object) = @_;
  my %query_form = $request->uri->query_form;

  return
    "/" .
    $call_object->account_name .
    $request->uri->path .
    join("",
      map { "\n" . lc($_) . ":" . $query_form{$_} } # TODO: params with multiple values
      sort
      keys %query_form
    );
}

__PACKAGE__->meta->make_immutable();

1;
