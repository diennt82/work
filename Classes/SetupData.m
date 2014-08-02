//
//  SetupData.m
//  MBP_ios
//
//  Created by NxComm on 4/25/12.
//  Copyright 2012 Hubble Connected Ltd. All rights reserved.
//

#import "SetupData.h"

@implementation SetupData

// used to save data
- (id)initWithChannels:(NSMutableArray *)channs andProfiles:(NSMutableArray *)cps
{
	self = [super init];
    if (self) {
        self.channels = channs;
        self.configuredCams = cps; // cps may be nil as it's not used
    }
	return self;
}

- (void)dealloc
{
    // Clean up the CamProfile/CamChannel release cycle bug
    for (CamChannel *channel in _channels) {
        [channel.profile setChannel:nil];
        [channel setCamProfile:nil];
    }
    
	[_channels release];
	[_configuredCams release];
    [super dealloc];
}

- (BOOL)saveSessionData
{
	int barker = DATA_BARKER;
	NSString *filename = [Util getDataFileName];
	
	FILE *fd = fopen([filename UTF8String], "wb");
	fwrite(&barker, sizeof(barker), 1, fd);
	
	/* Store channels
	 ?? : what if there are less then 4 channels ??*/
	int numberOfChannel = _channels.count;
	fwrite(&numberOfChannel, sizeof(int), 1, fd);
	
	NSMutableData *chann = nil;
	int data_len;
	
	for (int i = 0; i < _channels.count; i++) {
		chann = [_channels[i] getBytes];
		data_len = chann.length;
		fwrite(&data_len, sizeof(char), 1, fd);
		fwrite(chann.bytes, 1, chann.length, fd);
	}
    
	///Store cam profiles
	int numberOfProfiles = _configuredCams.count;
	fwrite(&numberOfProfiles,sizeof(int),1,fd);
	
	NSMutableData * cp = nil;
	
	for (int i = 0; i < _configuredCams.count; i++) {
		cp = [_configuredCams[i] getBytes];
		data_len = [cp length];
#if DEBUG_RESTORE_DATA
        NSLog(@"setup: profile len %d ", data_len);
#endif
		fwrite(&data_len,sizeof(int), 1,fd);
		fwrite([cp bytes], 1, [cp length], fd);
	}
	
	fflush(fd);
	fclose(fd);
	
	return TRUE;
}

- (BOOL)restoreSessionData
{
	NSString *file = [Util getDataFileName];
	FILE *fd = fopen([file UTF8String], "rb");
	if (fd == NULL) {
		return NO;
	}
	
    NSMutableData *channelData = [[NSMutableData alloc] init];
	CamChannel *channel1, *channel2, *channel3, *channel4;

	// read barker
	int barker = -1;
	fread(&barker, sizeof(int), 1, fd);
	
	if (barker == DATA_BARKER) {
		int numberOfChannel = -1;
		fread(&numberOfChannel, sizeof(int), 1, fd);
		
		char len = -1;
		fread(&len, sizeof(char), 1, fd);
        
		char *buff = malloc(len);
		fread(buff, sizeof (char), len,fd);
		
		[channelData appendBytes:buff length:len];
		channel1 = [CamChannel restoreFromData:channelData];
		
		// clear data
		[channelData setLength:0];
		free(buff);
		
		fread(&len, sizeof(char), 1, fd);
		buff = malloc(len);
        
		fread(buff, sizeof (char), len,fd);
		[channelData appendBytes:buff length:len];
		channel2 = [CamChannel restoreFromData:channelData];
		
		// clear data
		[channelData setLength:0];
		free(buff);
		
		fread(&len, sizeof(char), 1, fd);
		buff = malloc(len);
        
		fread(buff, sizeof (char), len,fd);
		[channelData appendBytes:buff length:len];
		channel3 = [CamChannel restoreFromData:channelData];
		
		// clear data
		[channelData setLength:0];
		free(buff);
		
		fread(&len, sizeof(char), 1, fd);
		buff = malloc(len);
        
		fread(buff, sizeof (char), len,fd);
		[channelData appendBytes:buff length:len];
		channel4 = [CamChannel restoreFromData:channelData];
		
		// clear data
		[channelData setLength:0];
		free(buff);
		
		self.channels = [[NSMutableArray alloc] initWithObjects:channel1, channel2, channel3, channel4, nil];
        [_channels release];
		
		// restore cam profiles
		int numOfProfile = -1;
		fread(&numOfProfile, sizeof(int), 1, fd);
		self.configuredCams = [[NSMutableArray alloc] initWithCapacity:numOfProfile];
        [_configuredCams release];
        
		int cp_count = 0;
        int profile_len = -1 ;
        
		while (cp_count < numOfProfile) {
			//Read cam profile entry len
			fread(&profile_len, sizeof(int), 1, fd);
            
#if DEBUG_RESTORE_DATA
            NSLog(@"setup:restore profile len %d ", profile_len);
#endif
			buff = malloc(profile_len);
            
			// Read cam profile entry data
			fread(buff, sizeof (char), profile_len,fd);
            
			// re-use @channel_data buffer
			[channelData appendBytes:buff length:profile_len];
            
			CamProfile *cp = [CamProfile restoreFromData:channelData];
			[self.configuredCams addObject:cp];
			
			// clear data
			[channelData setLength:0];
			free(buff);
			cp_count ++;
		}
	}
    else {
        unlink([file UTF8String]);
        
#if DEBUG_RESTORE_DATA
        NSLog(@"Wrong data barker, delete the file ");
#endif
    }
	
    fclose(fd);
    [channelData release];
    
	return YES;
}

@end
