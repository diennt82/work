//
//  CamProfile.m
//  MBP_ios
//
//  Created by NxComm on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamProfile.h"


@implementation CamProfile

@synthesize scan_response,mac_address, ip_address,port, ptt_port;
@synthesize profileImage, channel,isSelected,isRemoteAccess;
@synthesize profileImageData;

@synthesize name, last_comm, minuteSinceLastComm, isInLocal;

@synthesize   soundAlertEnabled,tempHiAlertEnabled,tempLoAlertEnabled;

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

    self.profileImage = nil;
	
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
    self.profileImage = nil;
	
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


#define END_OF_RECORD 0xdeadbeef

- (NSMutableData *) getBytes
{
	NSMutableData * data = [[NSMutableData alloc] init];
	
	
	NSString * temp = @"nil";
	NSString * ip ;
	int myport,minute ; 
	char temp_len ;
	


	temp = self.mac_address;
	
	ip = self.ip_address;
	myport = self.port;
	
	//mac
	temp_len= [temp length];
	
	[data appendBytes:&temp_len length:1];
	[data appendBytes:[temp UTF8String] length:[temp length]];		
	
	
	//ip
	if (ip == nil)
	{
		ip = @"nil";
	}
     
    
	temp_len = [ip length];
	[data appendBytes:&temp_len length:1];
	[data appendBytes:[ip UTF8String] length:[ip length]];
	
	//port
	[data appendBytes:&myport length:sizeof(int)];
	

	
	//name
	temp = self.name; 
	if (self.name = nil)
	{
		temp =@"nil";
	}
	temp_len = [temp length];
	[data appendBytes:&temp_len length:1];
	[data appendBytes:[temp UTF8String] length:[temp length]];
	
    
    //alert status
    char alertStatus = (self.soundAlertEnabled == TRUE)?1:0; 
    [data appendBytes:&alertStatus length:sizeof(char)];
    alertStatus = (self.tempHiAlertEnabled == TRUE)?1:0; 
    [data appendBytes:&alertStatus length:sizeof(char)];
    alertStatus = (self.tempLoAlertEnabled == TRUE)?1:0; 
    [data appendBytes:&alertStatus length:sizeof(char)];
    
    
    
	//lastComm
	temp = self.last_comm; 
	if (self.last_comm = nil)
	{
		temp = @"none";
	}
	temp_len = [temp length];
	[data appendBytes:&temp_len length:1];
	[data appendBytes:[temp UTF8String] length:[temp length]];

    //self.minuteSinceLastComm
    minute= self.minuteSinceLastComm;
    [data appendBytes:&minute length:sizeof(int)];
	//NSLog(@"ip minute: %d", minute);
    
    
    if ( self.profileImage != nil)
    {
       
        NSData * imageData = UIImageJPEGRepresentation(self.profileImage , 1.0);
        int img_len; 
        img_len = [imageData length];
        [data appendBytes:&img_len length:sizeof(int)];
        [data appendBytes:[imageData bytes] length:[imageData length]];
        
         NSLog(@">>>>>>>>>stored snapshot, len:%d",img_len );
    }
    
    int endOfRec = END_OF_RECORD; 
    [data appendBytes:&endOfRec length:sizeof(int)];
    
    
    NSLog(@">>getBytes : profile len: %d", [data length]);
    
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
		this =[[CamProfile alloc] initWithMacAddr:mac];
				
		/* assume */
		if ( [mac isEqualToString:@"NOTSET"])
		{
			this.isRemoteAccess = YES;
		}
		
		
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
			this.ip_address = nil;
		}
		else
		{			
			this.ip_address = ip; 
		}
		free(_ip);

		//Port
		int mport = 0;
		NSRange port_range = {ip_range.location + len,4};
		
		[data getBytes:&mport range:port_range];
		
		if (this.ip_address == nil)
		{
			this.port = 0;	
		}
		else {
			this.port = mport; 
		}


		
		
		
		//name
		NSRange name_len_range = {port_range.location + 4,1};
		[data getBytes:&len range:name_len_range];
		char * _name = malloc(len+1);
		_name[len] = '\0';
		
		NSRange name_range = {name_len_range.location +1, len};
		
		[data getBytes:_name range:name_range];
		
		NSString * myName = [NSString stringWithUTF8String:_name];
		this.name = myName; 
		free(_name);		
		
		
        //sound alert status
        char alertStatus = 1;
        NSRange salertStatRange = {name_range.location + len,1}; 
        [data getBytes:&alertStatus range:salertStatRange];
        this.soundAlertEnabled = (alertStatus==1); 
        
         //temp hi alert status
        NSRange th_alertStatRange = {salertStatRange.location + 1,1}; 
        [data getBytes:&alertStatus range:th_alertStatRange];
        this.tempHiAlertEnabled = (alertStatus==1);
        
         //temp lo alert status
        NSRange tl_alertStatRange = {th_alertStatRange.location + 1,1}; 
        [data getBytes:&alertStatus range:tl_alertStatRange];
        this.tempLoAlertEnabled = (alertStatus==1);
        NSLog(@"alert stat: %d %d %d", this.soundAlertEnabled, this.tempHiAlertEnabled, this.tempLoAlertEnabled);
        
        
		//LastComm
		NSRange lastComm_len_range = {tl_alertStatRange.location + 1,1};
		[data getBytes:&len range:lastComm_len_range];
		char * _lastComm = malloc(len+1);
		_lastComm[len] = '\0';
		NSRange lastComm_range = {lastComm_len_range.location +1, len};
		
		[data getBytes:_lastComm range:lastComm_range];
		
		NSString * myLastComm = [NSString stringWithUTF8String:_lastComm];
		this.last_comm  = myLastComm;
		free(_lastComm);
		
		
        
        
        //self.minuteSinceLastComm
        int minute= 0;
        NSRange min_range = {lastComm_len_range.location + len+1,4};
		
		[data getBytes:&minute range:min_range];
		 
		this.minuteSinceLastComm = minute; 
		
		
        
        //Check if this is the end of record
        int endOfRec= 0;
        NSRange e_range = {min_range.location+4,4};
        [data getBytes:&endOfRec range:e_range]; 
        if (endOfRec != END_OF_RECORD)
        {
            NSLog(@"restored:111 May be some image"); 
            
            int img_len = 0; 
            NSRange img_len_range = {min_range.location+4,4};
            [data getBytes:&img_len range:img_len_range];
            NSLog(@"restored: ImageLen: %d", img_len); 
            
#if 0
            char * _img_data = malloc(len);
                      
            NSRange img_range = {img_len_range.location +4, img_len};
            
            [data getBytes:_img_data range:img_range];
            
            NSMutableData * img_data = [[NSMutableData alloc]initWithBytes:_img_data
                                                                    length:img_len];
            
            [NSData dataWithBytes:_img_data length:img_len];
            
            this.profileImage = [UIImage imageWithData:img_data]; 
            //this.profileImage = [[UIImage alloc]initWithData:img_data];
            
            
           
            NSLog(@"restored: restored image done"); 
            
            free(_img_data);	
#else
            
            
            
            NSRange img_range = {img_len_range.location +4, img_len};
            
            NSData *  img_data =[data subdataWithRange:img_range];
            
            this.profileImage = [UIImage imageWithData:img_data]; 
            //this.profileImage = [[UIImage alloc]initWithData:img_data];
            
            
            
            NSLog(@"restored: restored image done 112"); 

            
#endif
            
            
        }
        else
        {
            NSLog(@"restored: No image - End of record");
        }
        
        
		
	}
	
	free(mac_str);
	
	
	NSLog(@"restored: name:%@ mac:%@, ip:%@,prt:%d lastCom:%@ min:%d",this.name, 
		  this.mac_address, this.ip_address, this.port, this.last_comm, this.minuteSinceLastComm);
	
	return this;
}


@end
