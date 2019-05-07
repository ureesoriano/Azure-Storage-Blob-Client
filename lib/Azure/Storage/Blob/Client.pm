# ABSTRACT: Azure Storage Blob API client
package Azure::Storage::Blob::Client;
use Moose;
use Azure::Storage::Blob::Client::Caller;
use Azure::Storage::Blob::Client::Call::GetBlobProperties;
use Azure::Storage::Blob::Client::Call::ListBlobs;
use Azure::Storage::Blob::Client::Call::PutBlob;

our $VERSION = 0.01;

has caller => (
  is => 'ro',
  lazy => 1,
  default => sub {
    return Azure::Storage::Blob::Client::Caller->new();
  },
);
has account_name => (is => 'ro', isa => 'Str', required => 1);
has account_key => (is => 'ro', isa => 'Str', required => 1);
has api_version => (is => 'ro', isa => 'Str', default => '2018-03-28');

sub GetBlobProperties {
  my ($self, %params) = @_;
  my $call_object = Azure::Storage::Blob::Client::Call::GetBlobProperties->new(
    account_name => $self->account_name,
    api_version => $self->api_version,
    %params,
  );
  return $self->caller->request(
    $self->account_name,
    $self->account_key,
    $call_object,
  );
}

sub ListBlobs {
  my ($self, %params) = @_;
  my $call_object = Azure::Storage::Blob::Client::Call::ListBlobs->new(
    account_name => $self->account_name,
    api_version => $self->api_version,
    %params,
  );
  return $self->caller->request(
    $self->account_name,
    $self->account_key,
    $call_object,
  );
}

sub PutBlob {
  my ($self, %params) = @_;
  my $call_object = Azure::Storage::Blob::Client::Call::PutBlob->new(
    account_name => $self->account_name,
    api_version => $self->api_version,
    %params,
  );
  return $self->caller->request(
    $self->account_name,
    $self->account_key,
    $call_object,
  );
}

__PACKAGE__->meta->make_immutable();

1;
