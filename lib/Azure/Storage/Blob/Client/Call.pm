package Azure::Storage::Blob::Client::Call;
use Moose::Role;

requires 'endpoint';
requires 'method';
requires 'operation';

sub serialize_parameters {
  my $self = shift;
  return {
    map { $_ => $self->$_ }
    grep { $self->meta->get_attribute($_)->does('CallParameter') }
    $self->meta->get_attribute_list()
  };
}

1;
