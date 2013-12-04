package WWW::XKCD::AsText;

use warnings;
use strict;

our $VERSION = '0.003';

use Carp;
use URI;
use LWP::UserAgent;
use HTML::TokeParser::Simple;
use HTML::Entities;
use base 'Class::Data::Accessor';
__PACKAGE__->mk_classaccessors( qw(
    ua
    timeout
    uri
    error
    text
));

sub new {
    my $class = shift;
    croak "Must have even number of arguments to new()"
        if @_ & 1;

    my %args = @_;
    $args{ +lc } = delete $args{ $_ } for keys %args;

    $args{timeout} ||= 30;
    $args{ua} ||= LWP::UserAgent->new(
        timeout => $args{timeout},
        agent   => 'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.8.1.12)'
                    .' Gecko/20080207 Ubuntu/7.10 (gutsy) Firefox/2.0.0.12',
    );

    my $self = bless {}, $class;
    $self->timeout( $args{timeout} );
    $self->ua( $args{ua} );

    return $self;
}

sub retrieve {
    my ( $self, $id ) = @_;
    croak "Undefined ID argument to retrieve()"
        unless defined $id;

    $id =~ s/\s+//g;

    croak "ID number... must be a NUMBER"
        if $id =~ /\D/;

    $self->$_(undef)
        for qw(uri text error);

    my $comic_uri = $self->uri( URI->new("http://xkcd.com/$id/") );

    my $text_uri = URI->new('http://www.ohnorobot.com/transcribe.pl');
    $text_uri->query_form(
        comicid => 'apKHvCCc66NMg',
        url     => $comic_uri,
    );

    my $response = $self->ua->get( $text_uri );
    if ( $response->is_success ) {
        my $final_text = $self->_parse( $response->content );
        $final_text =~ s/\s*\n\s*/\n\n/g;
        return $final_text;
    }
    else {
        return $self->_set_error('Network error: ' . $response->status_line);
    }
}

sub _parse {
    my ( $self, $content ) = @_;
    my $parser = HTML::TokeParser::Simple->new( \$content );

    my %nav = (
        get_text_from_textarea => 0,
        level               => 0,
        look_for_p          => 0,
        is_p                => 0,
    );
    my $text = '';
    while ( my $t = $parser->get_token ) {
        if (
            $t->is_start_tag('textarea')
            and defined $t->get_attr('name')
            and $t->get_attr('name') eq 'transcription'
        ) {
            @nav{ qw(get_text_from_textarea  level) } = ( 1, 1 );
        }
        elsif ( $t->is_start_tag('td') ) {
            @nav{ qw(look_for_p  level) } = ( 1, 2 );
        }
        elsif (
            $nav{look_for_p} == 1
            and $t->is_text
            and $t->as_is =~ /Here's the transcription for this comic/
        ) {
            @nav{ qw(look_for_p  level) } = ( 2, 3 );
        }
        elsif ( $nav{look_for_p} == 2 and $t->is_start_tag('p') ) {
            @nav{ qw(is_p level) } = ( 1, 4 );
        }
        elsif ( $nav{is_p} and $t->is_text ) {
            $text .= $t->as_is;
        }
        elsif ( $nav{is_p} and $t->is_start_tag('BR') ) {
            $text .= "\n";
        }
        elsif ( $nav{is_p} and $t->is_end_tag('p') ) {
            return $self->text( decode_entities($text) );
        }
        elsif ( $nav{get_text_from_textarea} == 1
            and $t->is_end_tag('textarea')
        ) {
            return $self->_set_error(
                q|Doesn't seem to be any text for this comic|
            );
        }
        elsif ( $nav{get_text_from_textarea} == 1 and $t->is_text ) {
            return $self->text( decode_entities($t->as_is) );
        }
    }
    return $self->_set_error(q|Doesn't seem to be any text for this comic|);
}

sub _set_error {
    my ( $self, $error ) = @_;
    $self->error( $error );
    return;
}


1;
__END__

=encoding utf8

=head1 NAME

WWW::XKCD::AsText - retrieve text versions of comics on www.xkcd.com

=head1 SYNOPSIS

    use strict;
    use warnings;

    use WWW::XKCD::AsText;

    my $xkcd = WWW::XKCD::AsText->new;

    my $text = $xkcd->retrieve( 333 )
        or die $xkcd->error;

    printf "Text for comic on %s is:\n%s\n",
                $xkcd->uri, $text;

=head1 DESCRIPTION

The module retrieving L<http://xkcd.com> transcriptions which can be
found on L<http://www.ohnorobot.com/>. 

=head1 CONSTRUCTOR

=head2 new

    my $xkcd = WWW::XKCD::AsText->new;

    my $xkcd = WWW::XKCD::AsText->new(
        timeout => 10,
    );

    my $xkcd = WWW::XKCD::AsText->new(
        ua => LWP::UserAgent->new(
            timeout => 10,
            agent   => 'comicReader',
        ),
    );

Constructs and returns a brand new yummy juicy WWW::XKCD::AsText
object. Takes two arguments, both are I<optional>. Possible arguments are
as follows:

=head3 timeout

    ->new( timeout => 10 );

B<Optional>. Specifies the C<timeout> argument of L<LWP::UserAgent>'s
constructor, which is used for retrieving text.
B<Defaults to:> C<30> seconds.

=head3 ua

    ->new( ua => LWP::UserAgent->new( agent => 'Foos!' ) );

B<Optional>. If the C<timeout> argument is not enough for your needs
of mutilating the L<LWP::UserAgent> object used for retrieving, feel free
to specify the C<ua> argument which takes an L<LWP::UserAgent> object
as a value. B<Note:> the C<timeout> argument to the constructor will
not do anything if you specify the C<ua> argument as well. B<Defaults to:>
plain boring default L<LWP::UserAgent> object with C<timeout> argument
set to whatever C<WWW::XKCD::AsText>'s C<timeout> argument is
set to as well as C<agent> argument is set to mimic Firefox.

=head1 METHODS

=head2 retrieve

    my $text = $xkcd->retrieve( 333 )
        or die $xkcd->error;

Takes one mandatory argument which is the XKCD's comic number. If a network
error occured or text is not available for the comic returns either C<undef>
or an empty list depending on the context and the reason for the error
will be available via C<error()> method (see below). On success returns
comic's transcription as a scalar. Will C<croak()> if comic ID is not
a number or is not C<defined()>.

B<Note:> the module relies on user submitted transcriptions of comics,
therefore you are unlikely to be able to retrieve texts for newest comics.

=head2 error

    my $text = $xkcd->retrieve( 333 )
        or die $xkcd->error;

Takes no arguments, must be called after failed C<retrieve()> method. Returns
a human parsable error message describing why C<retrieve()> failed.


=head2 text

    my $text = $xkcd->text;

Must be called after a successfull call to C<retrieve()> method. Takes
no arguments, returns a transcription of the comic which was C<retrieve()>d
last.

=head2 uri

    my $comic_uri = $xkcd->uri;

Must be called after a successfull call to C<retrieve()> method. Takes no
arguments, returns L<URI> object pointing to the comic on L<http://xkcd.com>
ID of which you've specified in C<retrieve()>.

=head2 timeout

    my $timeout = $xkcd->timeout;

Takes no arguments, returns whatever you've specified as the C<timeout>
argument to the C<new()> method (or its default if you didn't specify
anything).

=head2 ua

    my $ua_obj = $xkcd->ua;

    $xkcd->ua( LWP::UserAgent->new( timeout => 10, agent => 'comicBook' ) ):

Returns an L<LWP::UserAgent> object which is used for retrieving comic
texts. Accepts one optional argument which must be an L<LWP::UserAgent>
object, if you specify it then whatever you specify will be used for
retrieving comic texts.

=head1 SEE ALSO

L<LWP::UserAgent>, L<URI>, L<http://xkcd.com>

=head1 AUTHOR

Zoffix Znet, C<< <zoffix at cpan.org> >>
(L<http://zoffix.com>, L<http://haslayout.net>)

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-xkcd-astext at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-XKCD-AsText>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::XKCD::AsText

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-XKCD-AsText>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-XKCD-AsText>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-XKCD-AsText>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-XKCD-AsText>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 Zoffix Znet, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
