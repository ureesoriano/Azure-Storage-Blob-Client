package Azure::Storage::Blob::Client;
use Moose;
use Azure::Storage::Blob::Client::ListBlobs;

our $VERSION = 0.01;

sub ListBlobs {
  my ($self, %params) = @_;
  my $call_object = Azure::Storage::Blob::Client::ListBlobs->new(%params);
  return $self->caller->request($call_object);
}

__PACKAGE__->meta->make_immutable();

1;
