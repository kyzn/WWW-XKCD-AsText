=head1 NAME

WWW::XKCD::AsText - retrieve text versions of comics on www.xkcd.com

=head1 SYNOPSIS

  use WWW::XKCD::AsText;

  my $xkcd = WWW::XKCD::AsText->new;
  my $text = $xkcd->retrieve(1);

=cut

package WWW::XKCD::AsText;

use warnings;
use strict;

use Carp;
use URI;
use JSON;
use Furl;
use Try::Tiny;

sub new {
  my $class = shift;
  return bless {furl => Furl->new}, $class;
}

=head1 METHODS

=head2 retrieve

Takes XKCD comic number, returns its transcript.

=cut

sub retrieve {
  my ($self, $id) = @_;
  croak 'ID must be a valid number' unless $id && $id=~/^\d{1,6}$/;

  my ($xkcd_url, $furl_get, $decoded, $transcript);

  $xkcd_url = URI->new("http://xkcd.com/$id/info.0.json");
  $furl_get = $self->{furl}->get($xkcd_url);
  croak 'Cannot retrieve '. ($id // 'undef') unless $furl_get->is_success;

  try {
    $decoded = decode_json($furl_get->content);
  } catch {
    croak 'Cannot decode JSON for '. ($id // 'undef');
  };

  $transcript = $decoded->{transcript};

  croak 'No transcript found for '. ($id // 'undef') unless $transcript;
  return $transcript;
}

1;

=head1 SEE ALSO

L<WWW:xkcd>

=head1 AUTHOR

Original author is Zoffix Znet, E<lt>zoffix@cpan.orgE<gt>,
currently maintained by Kivanc Yazan, E<lt>kyzn@cpan.orgE<gt>.

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__END__