CROSS_COMPILE = mipsel-none-linux-gnu-

CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld

CFLAGS = -std=c99 -O2 -march=mips32r2 -Wall
LDFLAGS = -s

all: yamon.cgi phy-config.srec

%.cgi: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $^

%.srec: %.o
	$(LD) -Ttext=0x90000000 -e _ftext --oformat=srec -o $@ $<

.SECONDARY:
