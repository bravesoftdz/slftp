SHELL = /bin/bash
SLFTPPATH = ~/slftp
CC = fpc
CFLAGS = -MDelphi -O3 -Xs -Cg-
CINCLUDES = 
CDBFLAGS = -MDelphi -gl -gp -gs -gw3 -Cg-
default: clean cryptconf

all: cryptconf install

all_32: cryptconf_32 install

all_64: cryptconf_64 install
cryptconf:
	make clean
	$(CC) $(CFLAGS) $(CINCLUDES) cryptconf.dpr

cryptconf_32:
	make clean
	$(CC) -Pi386 $(CFLAGS) $(CINCLUDES) cryptconf.dpr

cryptconf_64:
	make clean
	$(CC) -Px86_64 $(CFLAGS) $(CINCLUDES) cryptconf.dpr

cryptconf_debug:
	$(CC) $(CDBFLAGS) $(CINCLUDES) cryptconf.dpr

cryptconf_32_debug:
	$(CC) -Pi386 $(CDBFLAGS) $(CINCLUDES) cryptconf.dpr

cryptconf_64_debug:
	$(CC) -Px86_64 $(CDBFLAGS) $(CINCLUDES) cryptconf.dpr

clean:
	@rm -f *.ppu *.o cryptconf *.exe

install:
	@cp cryptconf $(SLFTPPATH)/
