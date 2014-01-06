#
# author: Yoshiki Vazquez Baeza
# e-mail: yoshiki89@gmail.com
#

EX=mbu
CC=cc
FRAMEWORKS = -framework Foundation -framework QTKit -framework AppKit
CFLAGS = -fobjc-arc $(FRAMEWORKS)
#  Main target
all: $(EX)

mbu:
	$(CC) $(CFLAGS) -o mbu MovieBuilder/main.m

install: clean mbu
	mv mbu /usr/bin/

#  Delete unwanted files
clean:
	rm -f $(EX) *.o *.gch *.zip *.a *~

