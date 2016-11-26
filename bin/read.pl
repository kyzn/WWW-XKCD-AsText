#!/usr/bin/env perl

use strict;
use warnings;

use lib qw(../lib lib);

die "Usage: perl read.pl <comic_ID>\n"
    unless @ARGV;

my $ID = shift;

use lib '../lib';
use WWW::XKCD::AsText;

my $xkcd = WWW::XKCD::AsText->new;

my $text = $xkcd->retrieve( $ID )
    or die $xkcd->error;

printf "Text for comic on %s is:\n%s\n",
            $xkcd->uri, $text;