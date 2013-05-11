use strict;
use warnings;
use ExtUtils::MakeMaker;
use PDL::Core::Dev;
PDL::Core::Dev->import();

my $f77;

BEGIN {

    eval "use ExtUtils::F77";
    if ( $@ ne "" ) {
        warn
          "\n\tExtUtils::F77 module not found. Will not build PDL::Opt::NonLinear\n\n";
        exit(1);
    } else {
        $f77 = 'ExtUtils::F77';
    }

    my $compiler_available = $f77->testcompiler;
    if ( !$compiler_available ) {
        warn
          "\n\n\tNo fortran compiler found. Will not build PDL::Opt::NonLinear on this system\n\n";
        exit(1);
    }
}

our @pack = ( [qw(qp.pd QP PDL::Opt::QP)] );
my @src_files = map { s{^ src/ | .f $}{}xg; $_ } glob("src/*.f");
my $obj_files = join ' ', map { "src/$_.o" } @src_files;

my %hash = pdlpp_stdargs(@::pack);
$hash{INC}     .= " -Isrc";                       # uncomment as required
$hash{OBJECT}  .= " src/solve.QP.o $obj_files";
$hash{LDFROM}  .= " $obj_files QP.o";
$hash{LIBS}[0] .= $f77->runtime;
$hash{LIBS}[0] .= ' -L/opt/local/lib -lport -lblas -lgfortran';
$hash{clean}{FILES} .= " f77_underscore $obj_files";

# Handle multiple compilers

my $f2cbased = ( $f77->runtime =~ /-lf2c/ );
my $g2cbased = ( $f77->runtime =~ /-lg2c/ ) unless $f2cbased;
my $trail    = $f77->trail_;

# Create flag file according to whether or not to use
# underscores (pretty hacky)

unlink("f77_underscore") if -e "f77_underscore";
if ($trail) {
    open OUT, ">f77_underscore" or die "unable to write scratch file";
    close OUT;
}

WriteMakefile(
    %hash,
    VERSION_FROM => "",       # This is overridden by VERSION_FROM in %hash
    VERSION      => "0.01",
    'PREREQ_PM'  => {
        PDL => '2.00',
      }

);

sub MY::postamble {
    my $mycompiler = $f77->compiler();
    my $mycflags   = $f77->cflags();             #." -ff2c ";
    my $orig       = pdlpp_postamble(@::pack);

    # Make sure one space after colon
    $orig =~ s/:\s*qp.pd/: qp.pd/;

    # Add .f -> .o statement for each src file
    $orig .= <<SRC_COMPILATION

src/$_\$(OBJ_EXT): src/$_.f 
	$mycompiler -c -o src/$_\$(OBJ_EXT) $mycflags -O3 -fPIC src/$_.f
SRC_COMPILATION
      for @src_files;

    return $orig;
}
