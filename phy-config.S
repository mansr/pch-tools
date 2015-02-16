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

#include <regdef.h>

#define MDIO_CMD	0xa0026020
#define MDIO_CMD_GO	(1 << 31)
#define MDIO_CMD_WR	(1 << 26)
#define MDIO_ADDR_SHIFT	21
#define MDIO_REG_SHIFT	16

#define PHY_ID		1

	.set		noreorder

entry:
	move		s1, ra
	li		s0, MDIO_CMD

	li		a0, PHY_ID
	li		a1, 31
	bal		phy_write
	li		a2, 1

	li		a1, 28
	bal		phy_write
	li		a2, 0x5000

	li		a1, 31
	li		a2, 0
	b		phy_write
	move		ra, s1

.macro	delay
	li		t1, 6000
10:	bnez		t1, 10b
	addi		t1, t1, -1
.endm

phy_write:
1:	lw		t0, 0(s0)
	srl		t0, t0, 31
	bnez		t0, 1b
	nop
	sll		t0, a0, MDIO_ADDR_SHIFT
	sll		a1, a1, MDIO_REG_SHIFT
	or		t0, t0, a1
	or		t0, t0, a2
	sw		t0, 0(s0)
	delay
	or		t0, t0, MDIO_CMD_WR
	sw		t0, 0(s0)
	delay
	or		t0, t0, MDIO_CMD_GO
	jr		ra
	sw		t0, 0(s0)
