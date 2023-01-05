use strict;
use warnings;
use ExtUtils::MakeMaker;
use PDL::Core::Dev;
use ExtUtils::F77;
my $f77 = 'ExtUtils::F77';
die "No fortran compiler found. Will not build PDL::Opt::QP on this system\n" if !$f77->testcompiler;

# from PDL::Opt::NonLinear
my @pack = qw(qp.pd QP PDL::Opt::QP);
my @ffiles = map {s/\.f$//; $_} glob("*.f");
my $fobj = join ' ', map {"$_\$(OBJ_EXT)"} @ffiles;
my %hash = pdlpp_stdargs(\@pack);
$hash{OBJECT} .= " $fobj";
$hash{LIBS}[0] .= $f77->runtime . ' -lblas' ;
$hash{clean}{FILES} .= " $fobj";

# from PDL::LinearAlgebra
our $inc = '-DF77_USCORE='. ($f77->trail_ ? '_' : '');
$hash{INC} .= " $inc";

WriteMakefile(
  %hash,
  LICENSE           => 'perl',
  'CONFIGURE_REQUIRES' =>  { "PDL" => '2.063', "ExtUtils::F77" => 0 },
  'PREREQ_PM' => {
    'PDL' => '2.063',
  },
  TEST_REQUIRES => {
      'Test::More'      => '0.88',
      'Test::Exception' => 0,
  },
  META_MERGE => {
    "meta-spec" => { version => 2 },
    resources => {
      repository  => {
        url => 'git://github.com/mvgrimes/pdl-opt-qp.git',
        type => 'git',
        web => 'https://github.com/mvgrimes/pdl-opt-qp',
      },
      bugtracker => {web=>'https://github.com/mvgrimes/pdl-opt-qp/issues'},
    },
    x_IRC => 'irc://irc.perl.org/#pdl',
  },
);

sub MY::postamble {
        my $mycompiler     = $f77->compiler;
        my $mycflags       = $f77->cflags;
        my $orig = pdlpp_postamble(\@pack);
        $orig =~ s/:\s*qp\.pd/: qp.pd/;
        $orig .= <<EOF;

FC = $mycompiler
FFLAGS = $mycflags -O3 -fPIC

EOF
        $orig .join "",map {
("
$_\$(OBJ_EXT): $_.f
\t\$(FC) -c -o \$@ \$(FFLAGS) \$<
" )} @ffiles;
}
