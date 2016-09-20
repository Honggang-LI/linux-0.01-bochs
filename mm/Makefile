CC	=gcc
CFLAGS	=-m32 -O -Wall -fstrength-reduce  -fomit-frame-pointer \
	-finline-functions -nostdinc -I../include -Werror
AS	=as
AR	=gar
LD	=ld
LDFLAGS =-m elf_i386 -x
CPP	=gcc -E -nostdinc -I../include

.c.o:
	$(CC) $(CFLAGS) \
	-c -o $*.o $<
.s.o:
	$(AS) -32 -o $*.o $<
.c.s:
	$(CC) $(CFLAGS) \
	-S -o $*.s $<

OBJS	= memory.o page.o

all: mm.o

mm.o: $(OBJS)
	$(LD) $(LDFLAGS) -r -o mm.o $(OBJS)

clean:
	rm -f core *.o *.a tmp_make
	for i in *.c;do rm -f `basename $$i .c`.s;done

dep:
	sed '/\#\#\# Dependencies/q' < Makefile > tmp_make
	(for i in *.c;do $(CPP) -M $$i;done) >> tmp_make
	cp tmp_make Makefile

### Dependencies:
memory.o : memory.c ../include/signal.h ../include/sys/types.h \
  ../include/linux/config.h ../include/linux/head.h ../include/linux/kernel.h \
  ../include/asm/system.h 
