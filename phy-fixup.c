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

#define _DEFAULT_SOURCE

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/sockios.h>
#include <linux/mii.h>

#define IFNAME "eth0"

int main(void)
{
	struct ifreq ifr;
	struct mii_ioctl_data *mii;
	int sock;
	int err;

	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock < 0) {
		perror("socket");
		return 1;
	}

	memset(&ifr, 0, sizeof(ifr));
	strcpy(ifr.ifr_name, IFNAME);
	ifr.ifr_data = (char *)&mii;

	mii = (struct mii_ioctl_data *)&ifr.ifr_data;

	err = ioctl(sock, SIOCGMIIPHY, &ifr);
	if (err < 0) {
		perror("SIOCGMIIPHY");
		return 1;
	}

	mii->reg_num = 31;
	mii->val_in = 1;
	err = ioctl(sock, SIOCSMIIREG, &ifr);
	if (err) {
		perror("SIOCSMIIREG");
		return 1;
	}

	mii->reg_num = 28;
	mii->val_in = 0x5000;
	ioctl(sock, SIOCSMIIREG, &ifr);

	mii->reg_num = 31;
	mii->val_in = 0;
	ioctl(sock, SIOCSMIIREG, &ifr);

	close(sock);

	return 0;
}
