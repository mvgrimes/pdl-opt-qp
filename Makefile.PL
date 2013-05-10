use ExtUtils::MakeMaker;
use PDL::Core::Dev;
PDL::Core::Dev->import();
$abort = 0;
BEGIN {

   eval "use ExtUtils::F77";
   if ($@ ne "") {
     warn "\n\tExtUtils::F77 module not found. Will not build PDL::Opt::NonLinear\n\n" ;
     exit(1);
   }
   else {
     $f77 = 'ExtUtils::F77';
   }

   $compiler_available = $f77->testcompiler;

   if (!$compiler_available) {
     warn "\n\n\tNo fortran compiler found. Will not build PDL::Opt::NonLinear on this system\n\n";
     exit(1);
   } 
}

return if $abort;

@pack = (["qp.pd",QP,PDL::Opt::QP]);
@opti_libfiles = map {s/^src\///; s/\.f$//; $_} glob("src/*.f");

%hash = pdlpp_stdargs(@::pack);
$hash{INC} .= " -Isrc";  # uncomment as required
$hash{OBJECT} .= " src/solve.QP.o ";
$fobj = join '', map {" src/$_.o "} @opti_libfiles;
$hash{OBJECT} .= $fobj; 
$hash{LDFROM} .= " ".$fobj."QP.o";
$hash{LIBS}[0] .= $f77->runtime ;
$hash{LIBS}[0] .= ' -L/opt/local/lib -lport -lblas -lgfortran' ;
$hash{clean}{FILES} .= " f77_underscore" .
  join '', map {" src/$_.o "} @opti_libfiles;
$hash{clean}{FILES} .= " solve.QP.o ";

# Handle multiple compilers

$f2cbased = ($f77->runtime =~ /-lf2c/);
$g2cbased = ($f77->runtime =~ /-lg2c/) unless $f2cbased;
$trail = $f77->trail_;

# Create flag file according to whether or not to use
# underscores (pretty hacky)

unlink("f77_underscore") if -e "f77_underscore";
if ($trail) {
   open OUT, ">f77_underscore" or die "unable to write scratch file";
   close OUT;
}

WriteMakefile(
 %hash,
 VERSION_FROM => "",   # This is overridden by VERSION_FROM in %hash 
 VERSION => "0.01",
 'PREREQ_PM'		=> {
          PDL => '2.00',
          }

);

print "f77 = " , $f77->compiler() , "\n";

sub MY::postamble {
        $mycompiler     = $f77->compiler();
        $mycflags       = $f77->cflags();#." -ff2c ";
	my $orig = pdlpp_postamble(@::pack);
	$orig =~ s/:\s*nonlinear\.pd/: nonlinear.pd/;
	$orig .join "\n",map {
("
opti_lib/$_\$(OBJ_EXT): opti_lib/$_.f 
	$mycompiler -c -o opti_lib/$_\$(OBJ_EXT) $mycflags -O3 -fPIC opti_lib/$_.f
" )} @opti_libfiles;
 
}
