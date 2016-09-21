#include <stdio.h>	/* fprintf */
#include <stdlib.h>	/* contains exit */
#include <sys/types.h>	/* unistd.h needs this */
#include <unistd.h>	/* contains read/write */
#include <fcntl.h>
#include <string.h>

#define MINIX_HEADER 32
#define GCC_HEADER 1024

void die(char * str)
{
	fprintf(stderr,"%s\n",str);
	exit(1);
}

void usage(void)
{
	die("Usage: build boot system [> image]");
}

int main(int argc, char ** argv)
{
	int i,c,id,pading=0;
	char buf[1024];

	if (argc != 3)
		usage();

	memset(buf, 0, 1024);

	for (i=0;i<sizeof buf; i++) buf[i]=0;
	if ((id=open(argv[1],O_RDONLY,0))<0)
		die("Unable to open 'boot'");
	if (read(id,buf,MINIX_HEADER) != MINIX_HEADER)
		die("Unable to read header of 'boot'");
	if (((long *) buf)[0]!=0x04100301)
		die("Non-Minix header of 'boot'");
	if (((long *) buf)[1]!=MINIX_HEADER)
		die("Non-Minix header of 'boot'");
	if (((long *) buf)[3]!=0)
		die("Illegal data segment in 'boot'");
	if (((long *) buf)[4]!=0)
		die("Illegal bss in 'boot'");
	if (((long *) buf)[5] != 0)
		die("Non-Minix header of 'boot'");
	if (((long *) buf)[7] != 0)
		die("Illegal symbol table in 'boot'");
	i=read(id,buf,sizeof buf);
	fprintf(stderr,"Boot sector %d bytes.\n",i);
	fprintf(stderr, "Boot block is %d bytes.", i);
	if (i>512)
		die("Boot block may not exceed 512 bytes");
	buf[510]=0x55;
	buf[511]=0xAA;
	i=write(1,buf,512);
	if (i!=512)
		die("Write call failed");
	close (id);
	
	if ((id=open(argv[2],O_RDONLY,0))<0)
		die("Unable to open 'system'");
	//if (read(id,buf,GCC_HEADER) != GCC_HEADER)
	//	die("Unable to read header of 'system'");
	//if (((long *) buf)[5] != 0)
	//	die("Non-GCC header of 'system'");
	for (i=0 ; (c=read(id,buf,sizeof buf))>0 ; i+=c )
		if (write(1,buf,c)!=c)
			die("Write call failed");

	// pading to 512*n bytes
	if (i % 512) {
		memset(buf, 0, 1024);
		pading = 512 - i % 512;
		fprintf(stderr, "Pading %d bytes.\n", pading);
		if (write(1, buf, pading) != pading)
			die("Pading failed");
	}

	close(id);
	fprintf(stderr,"System %d bytes.\n",i);
	return(0);
}
