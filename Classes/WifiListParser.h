//
//  WifiListParser.h
//  MBP_ios
//
//  Created by NxComm on 6/29/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WifiListParser : NSObject <NSXMLParserDelegate>{

	NSXMLParser *xmlParser;
	NSMutableArray * wifiLists; 
}

@property (nonatomic, retain) NSMutableArray * wifiLists; 

@end
