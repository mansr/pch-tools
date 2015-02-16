/*
  Copyright (c) 2015 Mans Rullgard <mans@mansr.com>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define LR_CPU_BOOTSEL	0x1950
#define WATCHDOG	0xfd00

static inline void writel(uint32_t val, void *addr)
{
	*(volatile uint32_t *)addr = val;
	__asm__ volatile ("sync");
}

int main(void)
{
	char *sys, *cpu;
	int fd;

	fd = open("/dev/mem", O_RDWR | O_SYNC);
	if (fd < 0) {
		perror("/dev/mem");
		return 1;
	}

	sys = mmap(NULL, 0x10000, PROT_READ | PROT_WRITE, MAP_SHARED,
		   fd, 0x10000);
	if (sys == MAP_FAILED) {
		perror("mmap");
		return 1;
	}

	cpu = mmap(NULL, 0x10000, PROT_READ | PROT_WRITE, MAP_SHARED,
		   fd, 0x60000);
	if (sys == MAP_FAILED) {
		perror("mmap");
		return 1;
	}

	writel(0, cpu + LR_CPU_BOOTSEL);
	writel(270000, sys + WATCHDOG);
	writel(1, sys + WATCHDOG + 4);

	return 0;
}
