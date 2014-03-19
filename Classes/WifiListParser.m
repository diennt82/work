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
@synthesize isErrorParser  =_isErrorParser;

-(void) dealloc
{
	[wifiLists release];
	[xmlParser release];
    [super dealloc];
}

- (void)parseData:(NSData *) xmlWifiList whenDoneCall:(SEL) _parserCallback target:(id) obj
{
	//NSData * xmlData; <--- populate the xml content
#if 1
    _callback = _parserCallback;
    caller = obj;
	xmlParser = [[NSXMLParser alloc] initWithData:xmlWifiList];
	[xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
    
#else
    
    _callback = _parserCallback;
    caller = obj;
	
	//TEST
	NSString *path = [[NSBundle mainBundle] pathForResource:@"routers" ofType:@"xml"];
	NSURL *file_url = [NSURL fileURLWithPath:path];
	xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:file_url];
	[xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
#endif
}
- (void)parseData:(NSData *) xmlWifiList whenDoneCall:(SEL) _parserCallback whenErrorCall:(SEL) _parserErrorCallback target:(id) obj
{
    _callback = _parserCallback;
    caller = obj;
    _callbackError = _parserErrorCallback;
	xmlParser = [[NSXMLParser alloc] initWithData:xmlWifiList];
	[xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
}
#pragma mark -
#pragma mark NSXMLParserDelegate methods

#if 0
//Element Name:
#define WIFI_LIST_VERSION @"wifi_list"
#define WIFI_LIST_VERSION_ATT @"version"

#define NUM_ENTRY @"num_entries"
#define WIFI_ENTRY @"wifi"
#define WIFI_ENTRY_SSID @"ssid"
#define WIFI_ENTRY_BSSID @"bssid"
#define WIFI_ENTRY_AUTH_MODE @"auth_mode"
#define WIFI_ENTRY_QUALITY @"quality"
#define WIFI_ENTRY_SIGNAL_LEVEL @"signal_level"
#define WIFI_ENTRY_NOISE_LEVEL @"noise_level"
#define WIFI_ENTRY_CHANNEL @"channel"

#else 
//Element Name:
#define WIFI_LIST_VERSION @"wl"
#define WIFI_LIST_VERSION_ATT @"v"

#define NUM_ENTRY @"n"
#define WIFI_ENTRY @"w"
#define WIFI_ENTRY_SSID @"s"
#define WIFI_ENTRY_BSSID @"b"
#define WIFI_ENTRY_AUTH_MODE @"a"
#define WIFI_ENTRY_QUALITY @"q"
#define WIFI_ENTRY_SIGNAL_LEVEL @"si"
#define WIFI_ENTRY_NOISE_LEVEL @"nl"
#define WIFI_ENTRY_CHANNEL @"ch"


#endif


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"Document started");
    self.isErrorParser = YES;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Error: %@", [parseError localizedDescription]);
    if (_callbackError != nil)
    {
        [caller performSelector:_callbackError withObject:parseError];
    }
    self.isErrorParser = NO;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:WIFI_LIST_VERSION])
    {
        list_version = [attributeDict objectForKey:WIFI_LIST_VERSION_ATT];
    }
    
    if ([elementName isEqualToString:NUM_ENTRY])
    {
        currentStringValue = nil;
    }
    if ([elementName isEqualToString:WIFI_ENTRY])
    {
        currentEntry = [[WifiEntry alloc] init ];
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_SSID])
    {
        currentStringValue = nil;
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_BSSID])
    {
        currentStringValue = nil;
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_AUTH_MODE])
    {
        currentStringValue = nil;
    }
    
    
    if ([elementName isEqualToString:WIFI_ENTRY_QUALITY])
    {
        currentStringValue = nil;
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_SIGNAL_LEVEL])
    {
        //Do nothing for now
    }
    if ([elementName isEqualToString:WIFI_ENTRY_NOISE_LEVEL])
    {
        //Do nothing for now
    }
    if ([elementName isEqualToString:WIFI_ENTRY_CHANNEL])
    {
        //Do nothing for now
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
	
    if ([elementName isEqualToString:NUM_ENTRY])
    {
        if (currentStringValue != nil)
        {
            int numEntry = [currentStringValue intValue];
            
            wifiLists = [[NSMutableArray alloc] initWithCapacity:numEntry];
            
        }
        
        
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY])
    {
        if (wifiLists!=nil && currentEntry != nil)
        {
            [wifiLists addObject:currentEntry];
            
        }
    }
    
    
    if ([elementName isEqualToString:WIFI_ENTRY_SSID])
    {
        
        if (currentEntry != nil)
        {
            currentEntry.ssid_w_quote = currentStringValue;
            
        }
        
        
    }
    
    
    
    if ([elementName isEqualToString:WIFI_ENTRY_BSSID])
    {
        
        if (currentEntry != nil)
        {
            currentEntry.bssid = currentStringValue;
        }
        
    }
    
    
    
    
    if ([elementName isEqualToString:WIFI_ENTRY_AUTH_MODE])
    {
        
        if (currentEntry != nil)
        {
            if (currentStringValue == nil)
            {
                currentEntry.auth_mode = @"open";
            }
            else if ([currentStringValue hasPrefix:@"WPA"])
            {
                currentEntry.auth_mode = @"wpa";
            }
            else if ([currentStringValue hasPrefix:@"WEP"])
            {
                currentEntry.auth_mode = @"wep";
            }
            
            
        }
    }
    
    
    if ([elementName isEqualToString:WIFI_ENTRY_QUALITY])
    {
        if (currentEntry != nil)
        {
            if (currentStringValue == nil)
            {
                
            }
            else
            {
                currentEntry.quality = currentStringValue;
                
            }
            
            
        }
        
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_SIGNAL_LEVEL])
    {
        //Do nothing for now
    }
    if ([elementName isEqualToString:WIFI_ENTRY_NOISE_LEVEL])
    {
        //Do nothing for now
    }
    if ([elementName isEqualToString:WIFI_ENTRY_CHANNEL])
    {
        //Do nothing for now
    }
    
    
    //reset for the next element
    currentStringValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!currentStringValue) {
        // currentStringValue is an NSMutableString instance variable
        currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    [currentStringValue appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"Document finished");
    
    if (_callback != nil)
    {
        [caller performSelector:_callback withObject:wifiLists];
    }
}

- (BOOL)checkStatusParserXML
{
    return self.isErrorParser;
}
@end
