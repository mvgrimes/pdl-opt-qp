#!/usr/bin/env perl

use strict;
use warnings;
use Module::Build::Pluggable ( 'PDL', 'Fortran',
    'CheckLib' => { lib => 'blas', } );

my $builder = Module::Build::Pluggable->new(
    module_name       => 'PDL::Opt::QP',
    dist_version_from => 'lib/PDL/Opt/QP.pd',
    license           => 'perl',
    create_readme     => 1,

    extra_linker_flags => [qw{ -lblas }],
    f_source           => [qw{ src }],

    requires => {
        'PDL' => '2.00',
    },
    configure_requires => {
        'Module::Build'                      => '0.4004',
        'Module::Build::Pluggable'           => '0',
        'Module::Build::Pluggable::PDL'      => '0.20',
        'Module::Build::Pluggable::Fortran'  => '0.20',
        'Module::Build::Pluggable::CheckLib' => '1.00',

    },
    test_requires => {
        'Test::More'      => '0',
        'Test::Exception' => 0,
    },

    recursive_test_files => 1,

    meta_merge => {
        resources => {
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=PDL-Opt-QP',
            repository => 'http://github.com/mvgrimes/pdl-opt-qp'
        }
    },

    add_to_cleanup => [qw{PDL-Opt-QP-*}],
);

$builder->create_build_script();
