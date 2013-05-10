CC = gcc
# F77 = g77
F77 = /opt/local/bin/gfortran-mp-4.7
CFLAGS = -O3 -fPIC

all:    solve.QP.o

solve.QP.o : solve.QP.f
	$(F77) $(CFLAGS) -c solve.QP.f

clean : 
	rm *.o

