package Azure::Storage::Blob::Client::ListBlobs;
use Moose;
use Azure::Storage::Blob::Client::Meta::Attribute::Custom::Trait::CallParameter;
use XML::LibXML;

has operation => (is => 'ro', init_arg => undef, default => 'ListBlobs');
has endpoint => (is => 'ro', init_arg => undef, lazy => 1, default => sub {
  my $self = shift;
  return sprintf(
    'https://%s.blob.core.windows.net/%s?restype=container&comp=list',
    $self->account_name,
    $self->container,
  );
});
has method => (is => 'ro', init_arg => undef, default => 'GET');

with 'Azure::Storage::Blob::Client::Call';

has container => (is => 'ro', isa => 'Str', required => 1);
has account_name => (is => 'ro', isa => 'Str', required => 1);
has account_key => (is => 'ro', isa => 'Str', required => 1);
has prefix => (is => 'ro', isa => 'Str', traits => ['CallParameter'], required => 1);

sub parse_response {
  my ($self, $response) = @_;
  my $dom = XML::LibXML->load_xml(string => $response->content);

  return [
    map { $_->to_literal() } $dom->findnodes('/EnumerationResults/Blobs/Blob/Name')
  ];
}

__PACKAGE__->meta->make_immutable();

1;
