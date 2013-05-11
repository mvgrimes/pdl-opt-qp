use strict;
use warnings;
use Module::Build::PDL;

my @fortran_src_files = my @fortran_obj_files = glob("src/*.f");
s{\.f$}{.o} for @fortran_obj_files;

my $fortanlibs = ();

BEGIN {
    eval "use ExtUtils::F77";
    die "ExtUtils::F77 module not found. Will not build PDL::Opt::NonLinear\n"
      if $@;
    die "Not Fortran compiler found. Will not build PDL::Opt::NonLinear\n"
      unless ExtUtils::F77->runtimeok;
    die "No fortran compiler found. Will not build PDL::Opt::NonLinear"
      unless ExtUtils::F77->testcompiler;
    $fortanlibs = ExtUtils::F77->runtime;
}

my $class = Module::Build::PDL->subclass(
    class => "Module::Build::PDL::WithFortran",
    code  => <<'SUBCLASS' );

__PACKAGE__->add_property( 'fortran_src_files' );
sub ACTION_build {
    my $self = shift;

    use strict;
    use warnings;

    eval "use ExtUtils::F77";
    die "ExtUtils::F77 module not found. Will not build PDL::Opt::NonLinear\n"
      if $@;

    my $mycompiler = ExtUtils::F77->compiler();
    my $mycflags   = ExtUtils::F77->cflags();
    undef $mycflags if $mycflags =~ m{^\s*};

    my $fortran_src_files = $self->fortran_src_files;
    if( ref $fortran_src_files eq 'ARRAY' ){
        my @files = map { s{\.f$}{}; $_ } @$fortran_src_files;

        for my $file (@$fortran_src_files){
            my @cmd = ( $mycompiler, '-c', '-o', "${file}.o",
                        ( $mycflags || () ),
                        "-O3", "-fPIC", "${file}.f"
                      );
            print join( " ", @cmd), "\n";
            $self->do_system( @cmd )
                or die "error compiling $file";
        }
    }

    $self->SUPER::ACTION_build;
}
SUBCLASS

my $builder = $class->new(
    module_name       => 'PDL::Opt::QP',
    dist_version_from => 'lib/PDL/Opt/QP.pd',
    license           => 'perl',
    create_readme     => 1,

    extra_compiler_flags => [],
    ## Do we need $f77->runtime -lgfortran -lport or -L?
    ## TODO: Need to require blas or atlas or something
    extra_linker_flags => [ $fortanlibs, qw{ -lblas }, @fortran_obj_files ],
    fortran_src_files => [@fortran_src_files],

    requires => {
        'PDL' => '2.00',
    },
    configure_requires => {
        'Module::Build'      => '0.4004',
        'Module::Build::PDL' => '0.0.3',
    },
    build_requires => {
        'ExtUtils::F77'      => 0,
        'ExtUtils::CBuilder' => 0,

    },
    test_requires => {
        'Test::More' => '0',
    },

    recursive_test_files => 1,

    meta_merge => {
        resources => {
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=PDL-Opt-QP',
            repository => 'http://github.com/mvgrimes/pdl-opt-qp'
        }
    },

    add_to_cleanup => [ qw{PDL-Opt-QP-* f77_underscore}, @fortran_obj_files ],
);

$builder->create_build_script();

__END__
use strict;
use warnings;
use ExtUtils::CBuilder;
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
