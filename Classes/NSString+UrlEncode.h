//
//  NSString+UrlEncode.h
//  BlinkHD_ios
//
//  Created by Sven Resch on 2014-06-14.
//  Copyright (c) 2014 eBuyNow eCommerce Limited Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UrlEncode)

// Returns an URL encoded string
+ (NSString *)urlEncode:(NSString *)aString usingEncoding:(NSStringEncoding)encoding;

@end
