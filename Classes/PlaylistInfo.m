//
//  PlaylistInfo.m
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "PlaylistInfo.h"

@implementation PlaylistInfo

- (NSDate *)getTimeCode
{
    NSDate *triggeredDate = nil;
    
    // try to find the image file name [mac]_[type]_[time_code].jpg
    // for eg: 48022A2CAC31/snaps/48022A2CAC31_04_20130917065256730.jpg
    if ( _urlImage  && _macAddr ) {
        NSRange macRange = [_urlImage rangeOfString:_macAddr];
        NSRange extRange = [_urlImage rangeOfString:@".jpg"];
        
        if ( macRange.location != NSNotFound && extRange.location != NSNotFound ) {
            NSRange range = NSMakeRange(macRange.location, (extRange.location - macRange.location));
            NSString *macTypeTimecode =  [_urlImage substringWithRange:range];
            NSLog(@"mac_type_timecode: %@", macTypeTimecode);
            
            NSArray *tokens = [macTypeTimecode componentsSeparatedByString:@"_"];
            NSString *timecode = tokens[2];
            NSLog(@"timecode: %@", timecode);
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; // GMT +00:00
            
            triggeredDate = [formatter dateFromString:timecode];
        }
    }
    
    return triggeredDate;
}

- (NSString *)getAlertType
{
    NSString *type = nil;
    
    // try to find the image file name [mac]_[type]_[time_code].jpg
    // for eg: 48022A2CAC31/snaps/48022A2CAC31_04_20130917065256730.jpg
    if ( _urlImage  && _macAddr ) {
        NSRange macRange = [_urlImage rangeOfString:_macAddr];
        NSRange extRange = [_urlImage rangeOfString:@".jpg"];
        
        if ( macRange.location != NSNotFound && extRange.location != NSNotFound ) {
            NSRange range = NSMakeRange(macRange.location, (extRange.location - macRange.location));
            NSString *macTypeTimecode = [_urlImage substringWithRange:range];
            NSLog(@"mac_type_timecode: %@", macTypeTimecode);
            
            NSArray *tokens =  [macTypeTimecode componentsSeparatedByString:@"_"];
            type = [NSString stringWithFormat:@"%d", [tokens[1] intValue]];
            NSLog(@"type: %@", type);
        }
    }
    
    return type;
}

- (NSString *)getAlertVal
{
    NSString *val = nil;
    
    // try to find the image file name [mac]_[type]_[time_code].jpg
    // for eg: 48022A2CAC31/snaps/48022A2CAC31_04_20130917065256730.jpg
    if ( _urlImage  && _macAddr ) {
        NSRange macRange = [_urlImage rangeOfString:_macAddr];
        NSRange extRange = [_urlImage rangeOfString:@".jpg"];
        
        if ( macRange.location != NSNotFound && extRange.location != NSNotFound ) {
            NSRange range = NSMakeRange(macRange.location, (extRange.location - macRange.location));
            NSString * macTypeTimecode =  [_urlImage substringWithRange:range];
            NSLog(@"mac_type_timecode: %@", macTypeTimecode);
            
            NSArray *tokens =  [macTypeTimecode componentsSeparatedByString:@"_"];
            val = tokens[2];
            NSLog(@"val: %@", val);
        }
    }
    
    return val;
}

- (BOOL)isLastClip
{
    // try to find the image file name [mac]_[type]_[time_code].jpg
    // for eg: 48022A2CAC31/snaps/48022A2CAC31_04_20130917065256730_00001 or 8022A2CAC31/snaps/48022A2CAC31_04_20130917065256730_00001_last
    if ( _urlFile && _macAddr ) {
        NSRange macRange  =  [_urlFile rangeOfString:_macAddr];
        NSRange extRange  =  [_urlFile rangeOfString:@".flv"];
        
        if ( macRange.location != NSNotFound && extRange.location != NSNotFound ) {
            NSRange range = NSMakeRange(macRange.location, (extRange.location - macRange.location));
            NSString * macTypeTimecode =  [_urlFile substringWithRange:range];
            NSLog(@"mac_type_timecode: %@", macTypeTimecode);
            
            if ([macTypeTimecode hasSuffix:@"last" ]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)containsClip:(NSString *)aString
{
    if ( _urlFile && _macAddr ) {
        //one clip: http://s3.amazonaws.com/sm.wowza.content/44334C31A004/clips/44334C31A004_04_20130920084531940_00001.flv?AWSAccessKeyId=AKIAIDBFDZTAR2EB4KPQ&Expires=1379731654&Signature=F6grIs%2B91vMmSXC4OiRbqLOfbD8%3D
        //playlistInfo.url: http://s3.amazonaws.com/sm.wowza.content/44334C31A004/clips/44334C31A004_04_20130920084531940_00001.flv?AWSAccessKeyId=AKIAIDBFDZTAR2EB4KPQ&Expires=1379731665&Signature=Zgji%2B3dZQyuXOYtyLa3G%2Ffk%2FPqI%3D
        
        NSRange expiresRange = [_urlFile rangeOfString:@"&Expires="];
        if (expiresRange.location != NSNotFound) {
            NSString *substringUrlFile = [_urlFile substringToIndex:expiresRange.location];
            if([aString rangeOfString:substringUrlFile].location != NSNotFound) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
