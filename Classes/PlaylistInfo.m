//
//  PlaylistInfo.m
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "PlaylistInfo.h"

@implementation PlaylistInfo

@synthesize urlImage, mac_addr;

-(NSDate *) getTimeCode
{
    NSDate * triggeredDate  = nil;
    
    if (self.urlImage != nil )
    {
        
        //try to find the image file name [mac]_[type]_[time_code].jpg
        //for eg: 48022A2CAC31_04_20130917065256730.jpg // 12-char.jpg = 12 + 1 + 3  -> mac_range.loc = 0, ext_range =12 -> len = 12 - 0  = 12
        if (self.mac_addr != nil)
        {
            NSRange mac_range  =  [self.urlImage rangeOfString:self.mac_addr];
            NSRange ext_range  =  [self.urlImage rangeOfString:@".jpg"];
            
            if (mac_range.location != NSNotFound  &&
                ext_range.location != NSNotFound )
            {
                NSRange range = NSMakeRange(mac_range.location, (ext_range.location - mac_range.location));
                NSString * mac_type_timecode =  [self.urlImage substringWithRange:range];
                NSLog(@"mac_type_timecode: %@", mac_type_timecode);
                
                NSArray * tokens =  [mac_type_timecode componentsSeparatedByString:@"_"];
                
                NSString * timecode = [tokens objectAtIndex:2];
                NSLog(@"timecode: %@", timecode);
                
                NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
                [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
                //set GMT +00:00
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                

                 triggeredDate = [formatter dateFromString:timecode];
                
            }
            else
            {
                //NOT found jpg OR mac
            }
        }
        else
        {
            //NIL camera mac
        }
    }
    
    return triggeredDate; 
}
@end
