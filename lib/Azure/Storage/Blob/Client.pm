package Azure::Storage::Blob::Client;
use Moose;
use Azure::Storage::Blob::Client::Caller;
use Azure::Storage::Blob::Client::GetBlobProperties;
use Azure::Storage::Blob::Client::ListBlobs;
use Azure::Storage::Blob::Client::PutBlob;

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

sub GetBlobProperties {
  my ($self, %params) = @_;
  my $call_object = Azure::Storage::Blob::Client::GetBlobProperties->new(
    account_name => $self->account_name,
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
  my $call_object = Azure::Storage::Blob::Client::ListBlobs->new(
    account_name => $self->account_name,
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
  my $call_object = Azure::Storage::Blob::Client::PutBlob->new(
    account_name => $self->account_name,
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
