#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use PDL::LiteF;
use PDL::Opt::QP;

ok( defined &{'ok'}, "ok" );
ok( defined &{'qpgen2'}, "qpgen2" );

done_testing;
