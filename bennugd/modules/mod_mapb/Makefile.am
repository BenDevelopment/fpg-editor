## Process this file with automake to produce Makefile.in

#AUTOMAKE_OPTIONS = no-dependencies foreign

lib_LTLIBRARIES = libmod_mapb.la

libmod_mapb_la_SOURCES = file_graph.c file_grlib.c mod_mapb.c
libmod_mapb_la_CFLAGS = $(COMMON_CFLAGS) $(SDL_CFLAGS) -I$(BGD_PATH)/include -I$(BGD_PATH)/bgdrtm/include -I. -I../libbgload/ -I../librender/ -I../libfont/ -I../libblit/ -I../libvideo/ -I../libgrbase/
libmod_mapb_la_LDFLAGS = -s -module -no-undefined -avoid-version
libmod_mapb_la_LIBADD = $(COMMON_LDFLAGS) $(PNGLIBS) $(SDL_LIBS) -L../libbgload/.libs -lbgload -L$(BGD_PATH)/bgdrtm/src/.libs -lbgdrtm -L../librender/.libs -lrender -L../libfont/.libs -lfont -L../libblit/.libs -lblit -L../libvideo/.libs -lvideo -L../libgrbase/.libs -lgrbase -lpng

## Make sure these will be cleaned even when they're not built by
## default.
CLEANFILES = libmod_mapb.la
