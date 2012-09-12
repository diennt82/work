//
//  @interface NSData (NSData_Conversion)  #pragma mark - String Conversion - (NSString *)hexadecimalString; NSData+Conversion.m
//  MBP_ios
//
//  Created by NxComm on 9/5/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@implementation NSData (NSData_Conversion)

#pragma mark - String Conversion
- (NSString *)hexadecimalString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02x", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end