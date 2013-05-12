package Module::Build::PDL::Fortran;

use strict;
use warnings;
use parent qw(Module::Build::PDL);

__PACKAGE__->add_property('fortran_src_files');

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
    if ( ref $fortran_src_files eq 'ARRAY' ) {
        my @files = map { s{\.f$}{}; $_ } @$fortran_src_files;

        for my $file (@$fortran_src_files) {
            my @cmd = (
                $mycompiler, '-c', '-o', "${file}.o", ( $mycflags || () ),
                "-O3", "-fPIC", "${file}.f"
            );
            print join( " ", @cmd ), "\n";
            $self->do_system(@cmd)
              or die "error compiling $file";
        }
    }

    $self->SUPER::ACTION_build;
}

1;
