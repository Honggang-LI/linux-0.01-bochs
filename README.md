# linux-0.01-bochs
Running linux-0.01 with bochs

It had been built with a Fedora-24 x86-64 machine. To test it, please run:  

1) git clone https://github.com/HonggangLI/linux-0.01-bochs.git  
2) cd linux-0.01-bochs  
3) make  
4) tar -zxf hda.img.tar.gz  
5) cp hda.img hdb.img  
6) /PATH/TO/bochs -q -f b.rc  

Reference  
[1] http://www.oldlinux.org/  
[2] The Art of Linux Kernel Design: Illustrating the Operating System Design Principle and Implementation ISBN-10: 1466518030  
[3] linux 0.01 released, https://lwn.net/Articles/263562/  
