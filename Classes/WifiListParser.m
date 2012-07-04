//
//  WifiListParser.m
//  MBP_ios
//
//  Created by NxComm on 6/29/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "WifiListParser.h"


@implementation WifiListParser

@synthesize wifiLists; 


-(void) dealloc
{
	[wifiLists release];
	[xmlParser release];
    [super dealloc];
}

- (void)parseData:(NSData *) xmlWifiList
{
	//NSData * xmlData; <--- populate the xml content 
#if 0	
	xmlParser = [[NSXMLParser alloc] initWithData:xmlWifiList];
	[xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];

#endif 
	
	//TEST 
	NSString *path = [[NSBundle mainBundle] pathForResource:@"routers_list" ofType:@"xml"];
	NSURL *file_url = [NSURL fileURLWithPath:path];
	xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:file_url];
	[xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser 
{
    NSLog(@"Document started");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
    NSLog(@"Error: %@", [parseError localizedDescription]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{
   
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
	
   
}        

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}

- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
    NSLog(@"Document finished", nil);
}


@end
