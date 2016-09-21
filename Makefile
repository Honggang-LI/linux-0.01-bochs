#
# Makefile for linux.
# If you don't have '-mstring-insns' in your gcc (and nobody but me has :-)
# remove them from the CFLAGS defines.
#

AS86	=as86 -0 -a
CC86	=bcc -0
LD86	=ld86 -0

AS	=as
LD	=ld
LDFLAGS =-m elf_i386 -x -M
CC	=gcc
CFLAGS	=-m32 -Wall -O -fstrength-reduce -fomit-frame-pointer -Werror -fno-builtin
CPP	=gcc -E -nostdinc -Iinclude

ARCHIVES=kernel/kernel.o mm/mm.o fs/fs.o
LIBS	=lib/lib.a

.c.s:
	$(CC) $(CFLAGS) \
	-nostdinc -Iinclude -S -o $*.s $<
.s.o:
	$(AS) -32 -c -o $*.o $<
.c.o:
	$(CC) $(CFLAGS) \
	-nostdinc -Iinclude -c -o $*.o $<

all:	Image

Image: boot/boot tools/system tools/build
	tools/build boot/boot tools/system > Image
	sync

tools/build: tools/build.c
	$(CC) $(CFLAGS) \
	-o tools/build tools/build.c
	chmem +65000 tools/build

boot/head.o: boot/head.s

tools/system:   boot/head.o init/main.o \
	$(ARCHIVES) $(LIBS)
	$(LD) $(LDFLAGS) -Ttext 0 -e startup_32 boot/head.o init/main.o \
	$(ARCHIVES) \
	$(LIBS) \
	-o tools/system.org > System.map
	cp tools/system.org tools/system.tmp
	strip tools/system.tmp
	objcopy -O binary -R .note -R .comment tools/system.tmp tools/system

kernel/kernel.o:
	(cd kernel; make)

mm/mm.o:
	(cd mm; make)

fs/fs.o:
	(cd fs; make)

lib/lib.a:
	(cd lib; make)

boot/boot:      boot/boot.s tools/system
	A=$$(ls -l tools/system | grep system | cut -d ' ' -f5 | tr '\012' ' '); \
	B="($${A} + 15)/16"; \
	SIZE=$$(echo $${B} | bc);\
	echo "SYSSIZE = $$SIZE" > tmp.s
	cat boot/boot.s >> tmp.s
	$(AS86) -o boot/boot.o tmp.s
	rm -f tmp.s
	$(LD86) -s -o boot/boot boot/boot.o

clean:
	rm -f Image System.map tmp_make boot/boot core
	rm -f init/*.o boot/*.o tools/system tools/build
	(cd mm;make clean)
	(cd fs;make clean)
	(cd kernel;make clean)
	(cd lib;make clean)

backup: clean
	(cd .. ; tar cf - linux | compress16 - > backup.Z)
	sync

dep:
	sed '/\#\#\# Dependencies/q' < Makefile > tmp_make
	(for i in init/*.c;do echo -n "init/";$(CPP) -M $$i;done) >> tmp_make
	cp tmp_make Makefile
	(cd fs; make dep)
	(cd kernel; make dep)
	(cd mm; make dep)

### Dependencies:
init/main.o : init/main.c include/unistd.h include/sys/stat.h \
  include/sys/types.h include/sys/times.h include/sys/utsname.h \
  include/utime.h include/time.h include/linux/tty.h include/termios.h \
  include/linux/sched.h include/linux/head.h include/linux/fs.h \
  include/linux/mm.h include/asm/system.h include/asm/io.h include/stddef.h \
  include/stdarg.h include/fcntl.h 
