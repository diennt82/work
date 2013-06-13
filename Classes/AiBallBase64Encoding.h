//
//  AiBallBase64Encoding.h
//  AiBallRecorder
//
//  Created by sunjian on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//




@interface NSString (NSStringAdditions)

+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;

@end
