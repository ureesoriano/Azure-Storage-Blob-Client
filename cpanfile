requires 'Data::Dumper';
requires 'Digest::SHA';
requires 'Encode';
requires 'HTTP::Date';
requires 'HTTP::Headers';
requires 'HTTP::Request';
requires 'HTTP::Tiny';
requires 'LWP::UserAgent';
requires 'MIME::Base64';
requires 'Moose';
requires 'XML::LibXML';

on test => sub {
  requires 'Test::Spec::Acceptance';
  requires 'App::Prove::Watch';
};
