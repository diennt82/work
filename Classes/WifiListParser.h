//
//  WifiListParser.h
//  MBP_ios
//
//  Created by NxComm on 6/29/12.
//  Copyright 2012 Hubble Connected Ltd. All rights reserved.
//

#import "WifiEntry.h"

@interface WifiListParser : NSObject <NSXMLParserDelegate>

- (id)initWithNewCmdFlag:(BOOL)flag;
- (void)parseData:(NSData *)xmlWifiList whenDoneCall:(SEL)_parserCallback target:(id)obj;
- (void)parseData:(NSData *)xmlWifiList whenDoneCall:(SEL)_parserCallback whenErrorCall:(SEL)_parserErrorCallback target:(id)obj;
- (BOOL)checkStatusParserXML;

@end
