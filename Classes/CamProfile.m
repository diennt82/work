//
//  CamProfile.m
//  MBP_ios
//
//  Created by NxComm on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamProfile.h"


@implementation CamProfile

@synthesize scan_response,mac_address, ip_address,port;
@synthesize profileImage, channel,isSelected,isRemoteAccess;
@synthesize profileImageData;

@synthesize name, last_comm, minuteSinceLastComm, isInLocal;

-(void) initWithResponse:(NSString*) response andHost:(NSString *) host
{
	NSRange port_range ={16,8}; 
	NSString * port_str = [response substringWithRange:port_range]; 
	
	self.port = [port_str intValue];
	
	self.ip_address = host;
	self.scan_response =response;
	
	NSRange mac_range = {24,17};
	self.mac_address = [response substringWithRange:mac_range];
	self.mac_address = [self.mac_address uppercaseString];


	
	self.isRemoteAccess = NO;
}


/* To be used at restored time, there is only mac address */
- (id) initWithMacAddr:(NSString *) mac
{
	[super init];
	self.ip_address = nil;
	self.port  = 0;
	self.scan_response = nil;
	
	self.isRemoteAccess = NO;
	self.mac_address = mac;
	
	self.name = nil;
	self.last_comm = nil;
	self.minuteSinceLastComm = 100*24*60;//100 days
	
	return self;
}



- (void) dealloc
{
	[profileImageData release];
	[channel release];
	[scan_response release];
	[mac_address release];
	[ip_address release];
	[super	dealloc];
}

- (NSMutableData *) getBytes
{
	NSMutableData * data = [[NSMutableData alloc] init];
	
	
	NSString * temp = @"nil";
	NSString * ip ;
	int myport;
	char temp_len ;
	
	

	temp = self.mac_address;
	
	ip = self.ip_address;
	myport = self.port;
	
	NSLog(@"append mac: %@", temp );
	//mac
	temp_len= [temp length];
	
	[data appendBytes:&temp_len length:1];
	[data appendBytes:[temp UTF8String] length:[temp length]];		
	
	NSLog(@"append ip %@", ip);
	//ip
	temp_len = [ip length];
	[data appendBytes:&temp_len length:1];
	[data appendBytes:[ip UTF8String] length:[ip length]];
	
	NSLog(@"append port");
	//port
	[data appendBytes:&myport length:sizeof(int)];
	
	return data;
	
}

+ (CamProfile *) restoreFromData: (NSData *) data
{
	CamProfile * this = nil;
	
	unsigned char len = 0;
	
	

	
	
	NSRange mac_len_range = {0,1};
	[data getBytes:&len range:mac_len_range];
	
	
	
	NSRange mac_range = {1,len}; 
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
		this = nil;
	}
	else {
		/* skip over 1byte-mac_len + len bytes-mac */
		NSRange ip_len_range = {1+len,1};
		[data getBytes:&len range:ip_len_range];
		
		
		
		char * _ip = malloc(len+1);
		_ip[len] = '\0';
		
		NSRange ip_range = {ip_len_range.location +1, len};
		[data getBytes:_ip range:ip_range];
		
		
		
		NSString * ip = [NSString stringWithUTF8String:_ip];
		
		
		
		if ( [ip isEqualToString:@"nil"])
		{
			this = nil;
		}
		else
		{
			
			int mport = 0;
			NSRange port_range = {ip_range.location + len,4};
			
			[data getBytes:&mport range:port_range];
			
			
			this =[[CamProfile alloc] initWithMacAddr:mac];
			this.ip_address = ip; 
			this.port = mport;
			
			/* assume */
			if ( [mac isEqualToString:@"NOTSET"])
			{
				this.isRemoteAccess = YES;
			}
			
		}
		free(_ip);
	}
	
	free(mac_str);
	
	
	NSLog(@"restored: mac:%@, ip:%@,prt:%d",this.mac_address, this.ip_address, this.port);
	
	return this;
}


@end
