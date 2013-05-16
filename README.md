# NAME

PDL::Opt::QP - Quadratic programming solver for PDL

# SYNOPSIS

    use PDL;
    use PDL::NiceSlice;
    use PDL::Opt::QP;

    my $mu   = pdl(q[ 0.0427 0.0015 0.0285 ])->transpose; # [ n x 1 ]
    my $mu_0 = 0.0427;
    my $dmat = pdl q[ 0.0100 0.0018 0.0011 ;
                      0.0018 0.0109 0.0026 ;
                      0.0011 0.0026 0.0199 ];
    my $dvec = zeros(3);
    my $amat = $mu->glue( 0, ones( 1, 3 ) )->copy;
    my $bvec = pdl($mu_0)->glue( 1, ones(1) )->flat;
    my $meq  = pdl(2);

    my $sol = qp( $dmat, $dvec, $amat, $bvec, $meq );
    say "Solution: ", $sol->{x};

# DESCRIPTION

This routine uses Goldfarb/Idnani algorithm to solve the
following minimization problem:

           minimize  f(x) = 0.5 * x' D x  -  d' x
              x

    optionally constrained by:

            A' x  = a
            B  x >= b

# FUNCTIONS





## qpgen2

    Signature: (dmat(m,m); dvec(m); int fddmat(); int n();
          [o]sol(m); [o]lagr(q); [o]crval();
          amat(m,q); bvec(q); int fdamat(); int q(); int meq();
          int [o]iact(q); int [o]nact();
          int [o]iter(s=2); [t]work(z); int [io]ierr();
      )





This routine solves the quadratic programming optimization problem

           minimize  f(x) = 0.5 x' D x  -  d' x
              x

    optionally constrained by:

            A' x  = a
            B  x >= b



.... more docs to come ....



qpgen2 ignores the bad-value flag of the input piddles.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.



# SEE ALSO

[PDL](http://search.cpan.org/perldoc?PDL), [PDL::Opt::NonLinear](http://search.cpan.org/perldoc?PDL::Opt::NonLinear)

# BUGS

Please report any bugs or suggestions at [http://rt.cpan.org/](http://rt.cpan.org/)

# AUTHOR

Mark Grimes, <mgrimes@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Mark Grimes, <mgrimes@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
