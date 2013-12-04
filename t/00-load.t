#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 13;

BEGIN {
    use_ok('Carp');
    use_ok('URI');
    use_ok('LWP::UserAgent');
    use_ok('HTML::TokeParser::Simple');
    use_ok('HTML::Entities');
    use_ok('Class::Data::Accessor');
	use_ok( 'WWW::XKCD::AsText' );
}

diag( "Testing WWW::XKCD::AsText $WWW::XKCD::AsText::VERSION, Perl $], $^X" );
my $o = WWW::XKCD::AsText->new(timeout => 10);

isa_ok($o, 'WWW::XKCD::AsText');
can_ok($o, qw(    ua
    timeout
    uri
    error
    text
    retrieve
    _parse
    _set_error));

is( $o->timeout, 10, '->timeout() method' );

my $text = $o->retrieve( 1 );

my $VAR1 = "[[A boy sits in a barrel which is floating in an ocean.]]\n\nBoy: I wonder where I'll float next?\n\n[[The barrel drifts into the distance. Nothing else can be seen.]]\n\n{{Alt: Don't we all.}}";

SKIP: {
    if ( not defined $text ) {
        my $error = $o->error;
        ok( (defined $error and length $error), 'error is defined' );
        diag "Got retrieve() error: $error";
        skip "Got retrieve() error", 2;
    }
    is( $text, $VAR1, 'retrieve() must return specified text');
    isa_ok( $o->uri, 'URI::http' );
    isa_ok( $o->ua, 'LWP::UserAgent' );
}
