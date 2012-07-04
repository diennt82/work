//
//  CameraPassword.m
//  MBP_ios
//
//  Created by NxComm on 4/23/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "CameraPassword.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Util.h"

@implementation CameraPassword


@synthesize cameraUser, cameraPassword, cameraMacId;

+ (NSString* )fetchBSSIDInfo
{

#if TARGET_IPHONE_SIMULATOR == 1
	return @"00:0C:0A:46:02:26";
#else 
	
	
    NSArray *ifs = (id)CNCopySupportedInterfaces();

	
	if (ifs == nil)
	{
		return nil;
	}
	
    CFDictionaryRef info = nil;
    NSString * res= nil; 
    for (NSString *ifnam in ifs) {
		if (ifnam == nil)
		{
			NSLog(@"getBSSID: ifnam = nil");
			continue;
		}
        info = CNCopyCurrentNetworkInfo((CFStringRef)ifnam);


        if (CFDictionaryContainsKey(info,kCNNetworkInfoKeyBSSID) == true)
        {
            res = [NSString stringWithFormat:@"%@", CFDictionaryGetValue(info, kCNNetworkInfoKeyBSSID)];

        }




        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    [info autorelease];


    //make sure the format is right: "11:22:33:44:55:66"
    if (res != nil)
    {
        if ([res length] != 17)
        {
            NSLog(@"before : %@", res);
            NSMutableArray * addr_tok_ = [[NSMutableArray alloc] init];
            NSArray *addr_tok = [res componentsSeparatedByString:@":"];
            NSString * new_str; 
            for (int i=0; i<[addr_tok count]; i++)
            {
                new_str = [addr_tok objectAtIndex:i];
                if ([new_str length] != 2)
                {
                    //pre-pend a "0"
                    new_str = [NSString stringWithFormat:@"0%@",new_str];
                }

                if (i>0)
                {
                    //prepend ":" infront
                    new_str = [NSString stringWithFormat:@":%@",new_str];
                }

                [addr_tok_ addObject:new_str];
            }

            new_str = [NSString stringWithFormat:@""];
            for (int i=0; i<[addr_tok_ count]; i++)
            {
                new_str = [new_str stringByAppendingString:[addr_tok_ objectAtIndex:i]];
            }
                    
            res = new_str; 

            NSLog(@"after: %@", res);
        }
		
		
		res = [res uppercaseString];
    }



    return res;
#endif 
}

+ (NSString* )fetchSSIDInfo
{
	
#if TARGET_IPHONE_SIMULATOR == 1
	return @"NX-BROADBAND";
#else 
	
	CFDictionaryRef info = nil;
	NSString * res= nil; 
    NSArray *ifs = (id)CNCopySupportedInterfaces();
	if (ifs != nil)
	{
		
		for (NSString *ifnam in ifs) {
			if (ifnam == nil)
			{
				NSLog(@"getSSID: ifnam = nil");
				continue;
			}
			info = CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
			
			
			if (CFDictionaryContainsKey(info,kCNNetworkInfoKeySSID) == true)
			{
				res = [NSString stringWithFormat:@"%@", CFDictionaryGetValue(info, kCNNetworkInfoKeySSID)];
				
			}
			
			if (info && [info count]) {
				break;
			}
			[info release];
		}
		[ifs release];
		[info autorelease];
		
	}
    return res;
#endif 
}


+(BOOL) saveCameraPassword:(CameraPassword *) cp 
{
    NSMutableArray * camera_array; 
    camera_array = [[NSMutableArray alloc]init];
    NSString * old_pass; 
    CameraPassword * cpass; 
    int next_slot = -1; 

    /* check if this camera has an old pass */
    old_pass = [CameraPassword getPasswordForCam:cp.cameraMacId];
    if (old_pass != nil)
    {

        next_slot = [CameraPassword loadPasswordFromStore:&camera_array];
        for (int i = 0; i< [camera_array count]; i++)
        {
            cpass = [camera_array objectAtIndex:i]; 
            if ((cpass != nil) && 
                ([cpass.cameraMacId compare:cp.cameraMacId] == NSOrderedSame)
                   )
            {
                //Just replace dont change next_slot
                [camera_array replaceObjectAtIndex:i  withObject:cp];
                break;
            }
        }
        //store it back 
        //keep the same nxt_slot entry because we have not stored anything new 
        [CameraPassword savePasswordToStore:camera_array nextSlot:next_slot];
    }
    else
    {

        next_slot = [CameraPassword loadPasswordFromStore:&camera_array];
		NSLog(@"next_slot: %d");

		if ( next_slot >8 || next_slot <0)
		{
			next_slot = -1;
		}
		if (next_slot == -1)
		{
			next_slot =0;
		}
			
        if ([camera_array count] < 8)
        {
            [camera_array addObject:cp];
        }
        else
        {
            [camera_array replaceObjectAtIndex:next_slot withObject:cp];
        }

        [CameraPassword savePasswordToStore:camera_array nextSlot:((next_slot +1)%8)];

    }
    return TRUE;
}


/* 
 * 
 */
+(int) savePasswordToStore:(NSMutableArray * )camera_array nextSlot:(int) next
{
    NSString * filename = [Util getCPFileName];
    CameraPassword * cpass ; 
    int i ; 

    FILE * fd = fopen([filename UTF8String], "wb");
	if (fd == NULL)
		return -1; 
    NSData * data ; 
    int totallen = [camera_array count];
    fwrite(&totallen, sizeof (int), 1, fd);

		NSLog(@"write total:%d", totallen);
    fwrite(&next, sizeof(int),1, fd);

	NSLog(@"write nextslot:%d", next);
	
    for (i =0; i< [camera_array count]; i++)
    {
        cpass = [camera_array objectAtIndex:i];
        data = [cpass getBytes]; 
		NSLog(@"write entrt len :%d", [data length]);

        fwrite([data bytes],sizeof(char),[data length],fd); 
    }
	
	fflush(fd);
	fclose(fd);

    return 0; 
}


/* 
 * return next available slot to write to 
 *        camera_array stores the current remembered-password
 * 
 */
+(int) loadPasswordFromStore:(NSMutableArray ** )camera_array_
{
    NSString * filename = [Util getCPFileName];
    CameraPassword * cpass ; 
	NSMutableArray * camera_array = *camera_array_;
	NSLog(@"loadPasswordFromStore enter");
	
    //Try to open passwrd file : file must exist "r" 
    FILE * fd = fopen([filename UTF8String], "rb");

	//No need to init .. caller has to 
    //camera_array = [[NSMutableArray alloc] init];
	if (camera_array == nil)
	{
		NSLog(@"Cam array is not initialized");
		return -1; 
	}
    if (fd == NULL)
    {	

        NSLog(@"File %@ not exits", filename);
        return -1; 
    }

	
    int totalLen = -1; //in bytes
    fread(&totalLen, sizeof(int),1,fd);

	NSLog(@"loadPasswordFromStore len: %d",totalLen);
	
	
    int nextSlotIndex = -1;
    fread(&nextSlotIndex, sizeof(int), 1, fd);

	NSLog(@"loadPasswordFromStore nextSlotIndex: %d",nextSlotIndex);

    if (nextSlotIndex == -1)
    {
		fclose(fd);
        return -1;
    }

    //char * buff; 
    //	buff = malloc(totalLen); 
    //	fread(buff, sizeof (char), totalLen,fd);

    char * temp; 
	char temp_len = -1 ;
	int byte_read =0; 
	int cam_count = 0; 

    while (cam_count < totalLen)
    {
        cpass = [[CameraPassword alloc]init]; 

        byte_read += fread(&temp_len,1, 1, fd);
		

        temp = malloc(temp_len+1); 
        byte_read += fread(temp, 1, temp_len, fd);
		temp[temp_len] = '\0';
        cpass.cameraMacId = [NSString stringWithUTF8String:temp]; 
		NSLog(@"loadPasswordFromStore cameraMacIdlen: %@",cpass.cameraMacId);
		
		
        byte_read += fread(&temp_len, 1, 1, fd);
		NSLog(@"loadPasswordFromStore cameraUserlen: %d",temp_len);
        temp = malloc(temp_len+1); 
        byte_read += fread(temp, 1, temp_len, fd);
		temp[temp_len] = '\0';
        cpass.cameraUser = [NSString stringWithUTF8String:temp]; 

        byte_read += fread(&temp_len, 1, 1, fd);
		NSLog(@"loadPasswordFromStore cameraPasswordlen: %d",temp_len);
        temp = malloc(temp_len+1); 
        temp[temp_len] = '\0';
        byte_read += fread(temp, 1, temp_len, fd);
        cpass.cameraPassword = [NSString stringWithUTF8String:temp]; 

        [camera_array addObject:cpass];
		cam_count ++;
    } 

	
	fclose(fd);
    NSLog(@"after restore - entries: %d", [camera_array count]);
    return nextSlotIndex; 
}

+ (NSString*) getPasswordForCam:(NSString*) mac_address
{
    /* Load password store 
       find the camera passwith the corresponding mac 
       return the password
    */

    int next_slot = -1;
    NSMutableArray * campass = [[NSMutableArray alloc] init]; 
    CameraPassword * cp; 
    NSString * found_pass = nil;
    next_slot = [CameraPassword loadPasswordFromStore:&campass];

    if (next_slot == -1 )
    {
        //sth is wrong 
        // file not found, file content is corrupted
		return nil;
    }
	
	NSLog(@" next_slot: %d", next_slot);
    
    //mac_address should be of the form: 11:22:33:44:55:66
    for (int i=0; i<[campass count]; i++)
    {
        cp = [campass objectAtIndex:i];
        if ( (cp != nil) &&
             ([cp.cameraMacId compare:mac_address] ==  NSOrderedSame  )
           )
        {
            //Found pass for cam
            found_pass = cp.cameraPassword;
            break; 
        }
    }

    return found_pass;




}

















- (id) init
{
	[super init];
	
	self.cameraMacId = [NSString stringWithString:@""]; 
    self.cameraUser = [NSString stringWithString:@""]; 
    self.cameraPassword = [NSString stringWithString:@""];
	
	
    return self; 
	
}
- (id) initWithMac:(NSString*) mac User:(NSString *) user Pass:(NSString*) pass
{
    [super init];

    self.cameraMacId = mac; 
    self.cameraUser = user;
    self.cameraPassword = pass;

    return self; 
}


- (NSMutableData *) getBytes
{
    NSMutableData * data = [[NSMutableData alloc] init];

    char temp_len ; 

    temp_len= [self.cameraMacId length];

	
    [data appendBytes:&temp_len length:1];

    [data appendBytes:[self.cameraMacId UTF8String] length:[self.cameraMacId length]];		

    temp_len= [self.cameraUser length];

    [data appendBytes:&temp_len length:1];


    [data appendBytes:[self.cameraUser UTF8String] length:[self.cameraUser length]];		

    temp_len= [self.cameraPassword length];

    [data appendBytes:&temp_len length:1];


    [data appendBytes:[self.cameraPassword UTF8String] length:[self.cameraPassword length]];		


    return data;
}

- (void) dealloc
{
    [cameraMacId release];
    [cameraUser	 release];
    [cameraPassword release];
}





@end
