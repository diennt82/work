//
//  SetupData.m
//  MBP_ios
//
//  Created by NxComm on 4/25/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "SetupData.h"


@implementation SetupData

@synthesize channels, configured_cams; 

/* used when restoring data */
-(id) init
{
	[super init	];
	
	channels = nil; 
	configured_cams = nil; 
	
	
	return self;
}

/* used to save data */
-(id) initWithChannels:(NSMutableArray*)channs AndProfiles:(NSMutableArray*) cps
{
	[super init];
	channels = channs;
	//cps may be nil--- as it's not used 
	configured_cams = cps; 
	
	return self; 
}

- (void) dealloc
{
	[super dealloc];
	[channels release];
	[configured_cams release];
}

-(BOOL) save_session_data
{
	
	NSString * filename; 
	int barker = DATA_BARKER;
	filename = [Util getDataFileName];
	
	FILE  * fd = fopen([filename UTF8String], "wb");
	fwrite(&barker, sizeof(barker), 1, fd);
	
	/* Store channels
	 ?? : what if there are less then 4 channels ??*/
	int numberOfChannel = [self.channels count];
	fwrite(&numberOfChannel, sizeof(int), 1, fd);
	
	NSMutableData * chann= nil;
	char data_len; 
	
	for (int i =0; i< [self.channels count]; i++)
	{
		chann = [[self.channels objectAtIndex:i] getBytes];
		data_len = [chann length];
		fwrite(&data_len, sizeof(char), 1, fd);
		fwrite([chann bytes], 1, [chann length], fd);
	}

	///Store cam profiles
	int numberOfProfiles = [self.configured_cams count];
	fwrite(&numberOfProfiles,sizeof(int),1,fd);
	
	NSMutableData * cp = nil;
	
	for (int i = 0; i<[self.configured_cams count]; i++)
	{
		cp = [[self.configured_cams objectAtIndex:i] getBytes];
		data_len = [cp length];
		fwrite(&data_len,sizeof(char), 1,fd);
		fwrite([cp bytes], 1, [cp length], fd);
	}
	
	
	fflush(fd);
	fclose(fd);
	
	NSLog(@"write to file %@ done", filename);
	
	return TRUE;
	
}
-(BOOL) restore_session_data
{
	
	NSString * file = [Util getDataFileName];
	NSMutableData * channel_data;
	CamChannel * channel1, * channel2, * channel3, * channel4;
	channel_data = [[NSMutableData alloc] init];
	
	FILE * fd = fopen([file UTF8String], "rb");
	
	int barker = -1;
	
	if (fd == NULL)
	{
		
		return FALSE; 
	}
	
	
	/* read barker */
	fread(&barker, sizeof(int), 1, fd);
	
	//NSLog(@"barker = %x", barker);
	
	//if (barker == DATA_BARKER)
	{
		
		int numberOfChannel = -1;
		fread(&numberOfChannel, sizeof(int), 1, fd);
		
		char * buff;
		char len = -1;
		
		fread(&len, sizeof(char), 1, fd);
		buff = malloc(len);
		fread(buff, sizeof (char), len,fd);
		
		[channel_data appendBytes:buff length:len];
		channel1 = [CamChannel restoreFromData:channel_data];	
		
		/* clear data */
		[channel_data setLength:0];
		free(buff);
		
		
		fread(&len, sizeof(char), 1, fd);
		buff = malloc(len);
		fread(buff, sizeof (char), len,fd);
		[channel_data appendBytes:buff length:len];
		channel2 = [CamChannel restoreFromData:channel_data];	
		
		/* clear data */
		[channel_data setLength:0];
		free(buff);
		
		
		
		fread(&len, sizeof(char), 1, fd);
		buff = malloc(len);
		fread(buff, sizeof (char), len,fd);
		[channel_data appendBytes:buff length:len];
		channel3 = [CamChannel restoreFromData:channel_data];	
		
		/* clear data */
		[channel_data setLength:0];
		free(buff);
		
		
		fread(&len, sizeof(char), 1, fd);
		buff = malloc(len);
		fread(buff, sizeof (char), len,fd);
		[channel_data appendBytes:buff length:len];
		channel4 = [CamChannel restoreFromData:channel_data];	
		
		/* clear data */
		[channel_data setLength:0];
		free(buff);
		
		
		
		
		if ( self.channels != nil)
		{
			[self.channels release] ;
			self.channels  = nil; 
		}
		
		self.channels =[[NSMutableArray alloc] initWithObjects:channel1, channel2, channel3, channel4, nil];
		
		
		
		/*** restore cam profiles ***/
		
		
		CamProfile * cp; 
		
		int numOfProfile = -1; 
		fread(&numOfProfile, sizeof(int), 1, fd);
		self.configured_cams = [[NSMutableArray alloc] initWithCapacity:numOfProfile];
		int cp_count = 0; 

		while (cp_count < numOfProfile)
		{
		
			//Read cam profile entry len 
			fread(&len, sizeof(char), 1, fd);
			buff = malloc(len);
			//Read cam profile entry data
			fread(buff, sizeof (char), len,fd);
			//re-use @channel_data buffer  
			[channel_data appendBytes:buff length:len];
			cp = [CamProfile restoreFromData:channel_data];
			
			[self.configured_cams addObject:cp];
			
			/* clear data */
			[channel_data setLength:0];
			free(buff);
			cp_count ++;
		}
		
		
		[channel_data release];
		
		fclose(fd);
		
		
		
	}
	
	return TRUE;
}


@end
