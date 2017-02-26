# NAME

WWW::XKCD::AsText - retrieve text versions of comics on www.xkcd.com

# SYNOPSIS

    use WWW::XKCD::AsText;

    my $xkcd = WWW::XKCD::AsText->new;
    my $text = $xkcd->retrieve(1);

# METHODS

## retrieve

Takes XKCD comic number, returns its transcript.

# SEE ALSO

[WWW::xkcd](https://metacpan.org/pod/WWW::xkcd)

# AUTHOR

Original author is Zoffix Znet, `<zoffix at cpan.org>`,

currently maintained by Kivanc Yazan, `<kyzn at cpan.org>`.

# LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
