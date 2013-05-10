#!/usr/bin/env perl

use 5.014;
use strict;
use warnings;
use PDL::LiteF;
use PDL::Opt::QP;
use Test::More;

sub fapprox {
    my ( $a, $b ) = @_;
    PDL::abs( $a - $b )->max < 0.0001;
}

my $mu   = pdl(q[ 0.0427 0.0015 0.0285 ])->transpose;    # [ n x 1 ]
my $mu_0 = 0.0427;
my $dmat = pdl q[ 0.0100 0.0018 0.0011 ;
                  0.0018 0.0109 0.0026 ;
                  0.0011 0.0026 0.0199 ];
my $dvec = zeros(3);
my $amat = $mu->glue(0,ones(1,3))->copy;
my $bvec = pdl($mu_0)->glue(1, ones(1));
my $meq  = pdl(2);

say "n    = ", $mu->nelem;
say "amat = ", $amat;
say "dvec = ", $dvec;
say "bvec = ", $bvec;

my $sol   = null;
my $lagr  = null;
my $crval = null;
my $iact  = null;
my $nact  = null;
my $iter  = null;
my $ierr  = pdl(0);

# pp_def(
#     "qpgen2",
#     HandleBad => 0,
#     Pars      => 'dmat(n,n); dvec(n); amat(n,q); bvec(q); meq();
#     [o]sol(n); [o]lagr(q); [o]crval(); int [o]iact(q); int [o]nact();
#     int [o]iter(1,2); int [io]ierr()',

qp( $dmat, $dvec, $amat, $bvec, $meq );

my $expected_sol = pdl();
ok( fapprox( $sol, $expected_sol ) );

