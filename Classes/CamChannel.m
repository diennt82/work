//
//  CamChannel.m
//  MBP_ios
//
//  Created by NxComm on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamChannel.h"


@implementation CamChannel

@synthesize profile;
@synthesize channel_configure_status, channel_index;


- (id) initWithChannelIndex:(int) index
{
	channel_index = index;
	self.profile = nil;
	self.channel_configure_status = CONFIGURE_STATUS_NOT_ASSIGNED;
	return self;
}


- (BOOL) setCamProfile:(CamProfile *) cp
{
	if (cp == nil)
		return FALSE;
	
	self.channel_configure_status = CONFIGURE_STATUS_ASSIGNED;
	self.profile = cp;
	
	
	
	return TRUE;
	
}

- (void) setUnConfigure
{
	switch (self.channel_configure_status) {
		case CONFIGURE_STATUS_AWAITING_FOR_ASSIGNMENT:
			self.channel_configure_status = CONFIGURE_STATUS_NOT_ASSIGNED;
			
			break;
		default:
			break;
	}
	
}

- (BOOL) setConfigure
{
	switch (self.channel_configure_status) {
		case CONFIGURE_STATUS_NOT_ASSIGNED:
		case CONFIGURE_STATUS_ASSIGNED:
			if ( self.profile != nil)
			{
				self.profile.isSelected = FALSE;
				self.profile.channel = nil;
				self.profile = nil;
			}
			self.channel_configure_status = CONFIGURE_STATUS_AWAITING_FOR_ASSIGNMENT;
			
			break;
		default:
			break;
	}
	
	return TRUE;
}

- (void) reset
{
	self.channel_configure_status = CONFIGURE_STATUS_NOT_ASSIGNED;
	if (self.profile != nil)
	{
		[self.profile release];

	}
	self.profile = nil;
	
	
}


- (NSMutableData *) getBytes
{
	NSMutableData * data = [[NSMutableData alloc] init];
	
	int conf_status = self.channel_configure_status;
	
	[data appendBytes:&channel_index length:sizeof(int) ];
	[data appendBytes:&conf_status length:sizeof(int) ];
	

	
	NSString * temp = @"nil";
	NSString * ip ;
	int port;
	char temp_len ;
	
	if (self.profile != nil)
	{
		temp = self.profile.mac_address;
		
		ip = self.profile.ip_address;
		port = self.profile.port;
		

		//mac
		temp_len= [temp length];
		
		[data appendBytes:&temp_len length:1];
		[data appendBytes:[temp UTF8String] length:[temp length]];		


		//ip
		temp_len = [ip length];
		[data appendBytes:&temp_len length:1];
		[data appendBytes:[ip UTF8String] length:[ip length]];
		

		//port
		[data appendBytes:&port length:sizeof(int)];
		
		
	}
	else
	{
		temp_len= [temp length];
		
		//mac
		[data appendBytes:&temp_len length:1];
		[data appendBytes:[temp UTF8String] length:[temp length]];
		
		//ip
		[data appendBytes:&temp_len length:1];
		[data appendBytes:[temp UTF8String] length:[temp length]];
		
		//port
		[data appendBytes:&temp_len length:1];
		
	}

		
	return data;
}


+(CamChannel *) restoreFromData: (NSData *) data
{
	CamChannel * this = nil;
	
	
	NSRange index_range = {0,4};
	NSRange status_range = {4,4};
	int index = -1, conf_status = -1;
	unsigned char len = 0;
	
	[data getBytes:&index range:index_range];
	//NSLog(@"restored index = %d", index);
	
	[data getBytes:&conf_status range:status_range];
	//NSLog(@"restored status:%d", conf_status);
	
	this =[[CamChannel alloc] initWithChannelIndex:index];
	this.channel_configure_status = conf_status;
	
	
	NSRange mac_len_range = {8,1};
	[data getBytes:&len range:mac_len_range];


	
	NSRange mac_range = {9,len}; 
	char * mac_str = malloc(len+1);
	[data getBytes:mac_str range:mac_range];
	
	mac_str[len] = '\0';
	
	NSString * mac = [NSString stringWithUTF8String:mac_str];
	

	

	
	if ( mac == nil)
	{
		NSLog(@"mac is nil, cstring: %s", mac_str);
	}
	
	if ( [mac isEqualToString:@"nil"])
	{
		this.profile = nil;
	}
	else {
		
		NSRange ip_len_range = {9+len,1};
		[data getBytes:&len range:ip_len_range];
		

		
		char * _ip = malloc(len+1);
		_ip[len] = '\0';
		
		NSRange ip_range = {ip_len_range.location +1, len};
		[data getBytes:_ip range:ip_range];
		

		
		NSString * ip = [NSString stringWithUTF8String:_ip];
		
		

		if ( [ip isEqualToString:@"nil"])
		{
			this.profile = nil;
		}
		else
		{
			
			int port = 0;
			NSRange port_range = {ip_range.location + len,4};
			
			[data getBytes:&port range:port_range];
			
			
			this.profile = [[CamProfile alloc] initWithMacAddr:mac];
			this.profile.ip_address = ip; 
			this.profile.port = port;
			
			/* assume */
			if ( [mac isEqualToString:@"NOTSET"])
			{
				this.profile.isRemoteAccess = YES;
			}
			
		}
		free(_ip);
	}

	free(mac_str);
	
	return this;
	
}

-(void) dealloc
{
	if ( self.profile != nil)
		[profile release];
	
	[channel_view release];
	[super dealloc];
}

@end
