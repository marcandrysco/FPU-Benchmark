CFLAGS=-O2 -g


all: bench

bench: main.o asm.o
	gcc $^ -o $@ -ffast-math

main.o: main.c Makefile
	gcc $(CFLAGS) -c $< -o $@

asm.o: asm.s Makefile
	gcc -c $< -o $@

dist:
	if [ -e bench.dist ] ; then rm -rf bench.dist ; fi
	mkdir bench.dist
	cp Makefile asm.s main.c data.html data.css data.js bench.dist/
	tar -jcvf bench.dist.tar.bz2 bench.dist
	rm -rf bench.dist

run: all
	./bench | tee run.log

.PHONY: all dist run
