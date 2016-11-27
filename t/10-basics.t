use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;
use WWW::XKCD::AsText;

my $xkcd = WWW::XKCD::AsText->new;
isa_ok($xkcd, 'WWW::XKCD::AsText');

my $barrel = "[[A boy sits in a barrel which is floating in an ocean.]]
Boy: I wonder where I'll float next?
[[The barrel drifts into the distance. Nothing else can be seen.]]
{{Alt: Don't we all.}}";

is( $xkcd->retrieve(1), $barrel, 'returns correct text' );
dies_ok { $xkcd->retrieve(' ') } 'dies on \s';
dies_ok { $xkcd->retrieve('a') } 'dies on a';
dies_ok { $xkcd->retrieve( 0 ) } 'dies on 0';
dies_ok { $xkcd->retrieve( 999999 ) } 'dies on 999999';