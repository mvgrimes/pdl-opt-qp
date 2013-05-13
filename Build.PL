#!/usr/bin/env perl

use strict;
use warnings;
use lib qw{inc};
use Module::Build::PDL::Fortran;
use Devel::CheckLib;

my @fortran_src_files = my @fortran_obj_files = glob("src/*.f");
s{\.f$}{.o} for @fortran_obj_files;

sub fail { warn @_; exit 0; }

BEGIN {
    eval "use ExtUtils::F77";
    fail "ExtUtils::F77 module not found. Build not possible.\n"
      if $@;
    fail "No Fortran compiler found. Build not possible.\n"
      unless ExtUtils::F77->runtimeok;
    fail "No fortran compiler found. Build not possible.\n"
      unless ExtUtils::F77->testcompiler;

    eval "use Devel::CheckLib;";
    fail "Requires Devel::CheckLibs to build.\n"
      if $@;

    Devel::CheckLib::check_lib_or_exit( 'lib' => ['blas'] );
}

my $builder = Module::Build::PDL::Fortran->new(
    module_name       => 'PDL::Opt::QP',
    dist_version_from => 'lib/PDL/Opt/QP.pd',
    license           => 'perl',
    create_readme     => 1,

    extra_compiler_flags => [],
    ## TODO: Need to provide the option to use atlas instead of blas, etc.
    extra_linker_flags =>
      [ ExtUtils::F77->runtime, qw{ -lblas }, @fortran_obj_files ],
    fortran_src_files => [@fortran_src_files],

    requires => {
        'PDL' => '2.00',
    },
    configure_requires => {
        'Module::Build'      => '0.4004',
        'Module::Build::PDL' => '0.0.3',
        'Devel::CheckLibs'   => '0.99',
        'parent' => 0,
    },
    build_requires => {
        'ExtUtils::F77'      => 0,
        'ExtUtils::CBuilder' => 0,
    },
    test_requires => {
        'Test::More' => '0',
    },

    recursive_test_files => 1,
    release_status => 'testing',

    meta_merge => {
        resources => {
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=PDL-Opt-QP',
            repository => 'http://github.com/mvgrimes/pdl-opt-qp'
        }
    },

    add_to_cleanup => [ qw{PDL-Opt-QP-* f77_underscore}, @fortran_obj_files ],
);

$builder->create_build_script();
