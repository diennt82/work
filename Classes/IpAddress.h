/*
 *  IpAddress.h
 *  MBP_ios
 *
 *  Created by NxComm on 9/27/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#define MAXADDRS	32
#define INVALID_IP  0xdeadbeef

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *broadcast_addrs[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
int  GetIPAddresses();
void GetHWAddresses();