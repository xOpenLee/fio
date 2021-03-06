CC	= gcc
DEBUGFLAGS = -D_FORTIFY_SOURCE=2 -DFIO_INC_DEBUG
CPPFLAGS= -D_GNU_SOURCE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 \
	$(DEBUGFLAGS)
OPTFLAGS= -O2 -fno-omit-frame-pointer -g $(EXTFLAGS)
CFLAGS	= -std=gnu99 -Wwrite-strings -Wall $(OPTFLAGS) -rdynamic
LIBS	= -lpthread -lm -ldl -lrt -laio
PROGS	= fio
SCRIPTS = fio_generate_plots
	
SOURCE = gettime.c fio.c ioengines.c init.c stat.c log.c time.c filesetup.c \
	eta.c verify.c memory.c io_u.c parse.c mutex.c options.c rbtree.c \
	diskutil.c fifo.c blktrace.c smalloc.c filehash.c helpers.c \
	cgroup.c profile.c debug.c trim.c lib/rand.c lib/flist_sort.c \
	lib/num2str.c $(wildcard crc/*.c) engines/cpu.c engines/libaio.c \
	engines/mmap.c engines/posixaio.c engines/sg.c engines/splice.c \
	engines/sync.c engines/null.c engines/net.c engines/syslet-rw.c \
	engines/guasi.c engines/binject.c profiles/tiobench.c
	
OBJS = $(SOURCE:.c=.o)

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
	QUIET_CC	= @echo '   ' CC $@;
	QUIET_DEP	= @echo '   ' DEP $@;
endif
endif

INSTALL = install
prefix = /usr/local
bindir = $(prefix)/bin
mandir = $(prefix)/man

.c.o:
	$(QUIET_CC)$(CC) -o $@ -c $(CFLAGS) $(CPPFLAGS) $<
	
fio: $(OBJS)
	$(QUIET_CC)$(CC) $(CFLAGS) -o $@ $(LIBS) $(OBJS)

depend:
	$(QUIET_DEP)$(CC) -MM $(CFLAGS) $(CPPFLAGS) $(SOURCE) 1> .depend

$(PROGS): depend

all: depend $(PROGS) $(SCRIPTS)

clean:
	-rm -f .depend $(OBJS) $(PROGS) core.* core

cscope:
	@cscope -b -R

install: $(PROGS) $(SCRIPTS)
	$(INSTALL) -m755 -d $(DESTDIR)$(bindir)
	$(INSTALL) $(PROGS) $(SCRIPTS) $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 -d $(DESTDIR)$(mandir)/man1
	$(INSTALL) -m 644 fio.1 $(DESTDIR)$(mandir)/man1
	$(INSTALL) -m 644 fio_generate_plots.1 $(DESTDIR)$(mandir)/man1

ifneq ($(wildcard .depend),)
include .depend
endif
