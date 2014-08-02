//
//  NSString+UrlEncode.m
//  BlinkHD_ios
//
//  Created by Sven Resch on 2014-06-14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "NSString+UrlEncode.h"

@implementation NSString (UrlEncode)

+ (NSString *)urlEncode:(NSString *)aString usingEncoding:(NSStringEncoding)encoding
{
    CFStringRef stringRef = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                    (CFStringRef)aString,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();:@=+$,?%#[]% ",
                                                                    CFStringConvertNSStringEncodingToEncoding(encoding));
    // Create an NSString so we can call release on the CFStringRef.
    // TODO: --> will have to cast as follows after ARC conversion: (__bridge NSString *)
    NSString *encodedStr = [NSString stringWithString:(NSString *)stringRef];
    CFRelease(stringRef);
    
    return encodedStr;
}

@end
