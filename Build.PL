use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::XKCD::AsText',
    license             => 'perl',
    dist_author         => 'Zoffix Znet <zoffix@cpan.org>',
    dist_version_from   => 'lib/WWW/XKCD/AsText.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'URI'                      => 1.35,
        'Carp'                     => 1.04,
        'LWP::UserAgent'           => 2.036,
        'HTML::TokeParser::Simple' => 3.15,
        'HTML::Entities'           => 1.35,
        'Class::Data::Accessor'    => 0.04001,
        perl                       => 5.006,
    },
    configure_requires => { 'Module::Build' => 0 },
    add_to_cleanup      => [ 'WWW-XKCD-AsText-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
