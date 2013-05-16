#!/usr/bin/env perl

use 5.014;
use strict;
use warnings;
use PDL::LiteF;
use PDL::MatrixOps;
use PDL::Opt::QP;
use Test::More;
use Test::Exception;

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
my $amat = $mu      # mu' x = mu_0
  ->glue( 0, ones( 1, 3 ) )    # 1'  x = 1    (sum(x) = 1)
  ->copy;
my $avec = pdl($mu_0)->glue( 0, ones(1) )->copy;
my $bmat = null;
my $bvec = null;

{
    # diag "n    = ", $mu->nelem;
    # diag "dmat = ", $dmat;
    # diag "dvec = ", $dvec;
    # diag "amat = ", $amat;
    diag "avec = ", $avec;
    # diag "bmat = ", $bmat;
    # diag "bvec = ", $bvec;

    my $sol = qp( $dmat, $dvec, $amat, $avec, $bmat, $bvec );
    my $expected_sol = pdl [ 0.82745456, -0.090746123, 0.26329157 ];
    ok( fapprox( $sol->{x}, $expected_sol ), "Got expected solution" )
      or diag "Got $sol->{x}\nExpected: $expected_sol";
}

{
    $bmat = $bmat->glue( 0, identity(3) );
    $bvec = $bvec->glue( 0, zeros(3) )->flat;

    # diag "n    = ", $mu->nelem;
    # diag "dmat = ", $dmat;
    # diag "dvec = ", $dvec;
    # diag "amat'= ", $amat->transpose;
    # diag "avec = ", $avec;
    # diag "bmat'= ", $bmat->transpose;
    # diag "bvec = ", $bvec;

    my $sol = qp( $dmat, $dvec, $amat, $avec, $bmat, $bvec );
    my $expected_sol = pdl [ 1, 0, 0 ];
    ok( fapprox( $sol->{x}, $expected_sol ), "Got expected solution" )
      or diag "Got $sol->{x}\nExpected: $expected_sol";
}

done_testing;
