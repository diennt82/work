//
//  WifiListParser.h
//  MBP_ios
//
//  Created by NxComm on 6/29/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//


#import "WifiEntry.h"

@interface WifiListParser : NSObject <NSXMLParserDelegate>{

	NSXMLParser *xmlParser;
	NSMutableArray * wifiLists; 
    
    SEL _callback;
    SEL _callbackError;
    id  caller;
    
    NSMutableString * currentStringValue;
    NSString * list_version;
    WifiEntry * currentEntry;
    BOOL _isErrorParser;
}

@property (nonatomic, retain) NSMutableArray * wifiLists; 
@property (nonatomic, assign) BOOL isErrorParser;

- (void)parseData:(NSData *) xmlWifiList whenDoneCall:(SEL) _parserCallback target:(id) obj;

- (void)parseData:(NSData *) xmlWifiList whenDoneCall:(SEL) _parserCallback whenErrorCall:(SEL) _parserErrorCallback target:(id) obj;
- (BOOL)checkStatusParserXML;

@end
