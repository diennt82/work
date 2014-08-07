//
//  WifiListParser.m
//  MBP_ios
//
//  Created by NxComm on 6/29/12.
//  Copyright 2012 Hubble Connected Ltd. All rights reserved.
//

#import "WifiListParser.h"

@interface WifiListParser ()

@property (nonatomic, strong) NSMutableArray *wifiLists;
@property (nonatomic, assign) BOOL isErrorParser;

@property (nonatomic) SEL callback;
@property (nonatomic) SEL callbackError;
@property (nonatomic, weak) id  caller;

@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSMutableString *currentStringValue;
@property (nonatomic, strong) WifiEntry *currentEntry;
@property (nonatomic, copy) NSString *listVersion;

@end

#define WIFI_CMD @"%@"

NSString *WIFI_LIST_VERSION  = @"wifi_list";
NSString *WIFI_LIST_VERSION_ATT = @"version";

NSString *NUM_ENTRY = @"num_entries";
NSString *WIFI_ENTRY = @"wifi";
NSString *WIFI_ENTRY_SSID = @"ssid";
NSString *WIFI_ENTRY_BSSID = @"bssid";
NSString *WIFI_ENTRY_AUTH_MODE = @"auth_mode";
NSString *WIFI_ENTRY_QUALITY = @"quality";
NSString *WIFI_ENTRY_SIGNAL_LEVEL = @"signal_level";
NSString *WIFI_ENTRY_NOISE_LEVEL = @"noise_level";
NSString *WIFI_ENTRY_CHANNEL = @"channel";

@implementation WifiListParser

- (id)initWithNewCmdFlag:(BOOL)flag
{
    self = [super init];
    
    if (self) {
        if (flag) {
            WIFI_LIST_VERSION  = @"wl";
            WIFI_LIST_VERSION_ATT = @"v";
            
            NUM_ENTRY = @"n";
            WIFI_ENTRY = @"w";
            WIFI_ENTRY_SSID = @"s";
            WIFI_ENTRY_BSSID = @"b";
            WIFI_ENTRY_AUTH_MODE = @"a";
            WIFI_ENTRY_QUALITY = @"q";
            WIFI_ENTRY_SIGNAL_LEVEL = @"si";
            WIFI_ENTRY_NOISE_LEVEL = @"nl";
            WIFI_ENTRY_CHANNEL = @"ch";
        }
        else {
            WIFI_LIST_VERSION  = @"wifi_list";
            WIFI_LIST_VERSION_ATT  = @"version";
            
            NUM_ENTRY  = @"num_entries";
            WIFI_ENTRY = @"wifi";
            WIFI_ENTRY_SSID = @"ssid";
            WIFI_ENTRY_BSSID = @"bssid";
            WIFI_ENTRY_AUTH_MODE = @"auth_mode";
            WIFI_ENTRY_QUALITY = @"quality";
           WIFI_ENTRY_SIGNAL_LEVEL = @"signal_level";
            WIFI_ENTRY_NOISE_LEVEL = @"noise_level";
            WIFI_ENTRY_CHANNEL = @"channel";
        }
    }
    
    return self;
}

- (void)parseData:(NSData *) xmlWifiList whenDoneCall:(SEL) _parserCallback target:(id) obj
{
    self.callback = _parserCallback;
    self.caller = obj;
	self.xmlParser = [[NSXMLParser alloc] initWithData:xmlWifiList];
    
	[_xmlParser setDelegate:self];
    [_xmlParser setShouldProcessNamespaces:NO];
    [_xmlParser setShouldReportNamespacePrefixes:NO];
    [_xmlParser setShouldResolveExternalEntities:NO];
    [_xmlParser parse];
}

- (void)parseData:(NSData *) xmlWifiList whenDoneCall:(SEL) _parserCallback whenErrorCall:(SEL) _parserErrorCallback target:(id) obj
{
    self.callback = _parserCallback;
    self.caller = obj;
    self.callbackError = _parserErrorCallback;
    
	self.xmlParser = [[NSXMLParser alloc] initWithData:xmlWifiList];
    
	[_xmlParser setDelegate:self];
    [_xmlParser setShouldProcessNamespaces:NO];
    [_xmlParser setShouldReportNamespacePrefixes:NO];
    [_xmlParser setShouldResolveExternalEntities:NO];
    [_xmlParser parse];
}

#pragma mark - NSXMLParserDelegate methods

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

//#else
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
    if ( _callbackError ) {
        [_caller performSelector:_callbackError withObject:parseError];
    }
    self.isErrorParser = NO;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:WIFI_LIST_VERSION]) {
        self.listVersion = [attributeDict objectForKey:WIFI_LIST_VERSION_ATT];
    }
    
    if ([elementName isEqualToString:NUM_ENTRY]) {
        self.currentStringValue = nil;
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY]) {
        self.currentEntry = [[WifiEntry alloc] init];
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_SSID]) {
        self.currentStringValue = nil;
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_BSSID]) {
        self.currentStringValue = nil;
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_AUTH_MODE]) {
        self.currentStringValue = nil;
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_QUALITY]) {
        self.currentStringValue = nil;
    }
    
    /*
    if ([elementName isEqualToString:WIFI_ENTRY_SIGNAL_LEVEL]) {
        //Do nothing for now
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_NOISE_LEVEL]) {
        //Do nothing for now
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_CHANNEL]) {
        //Do nothing for now
    }
    */
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	
    if ([elementName isEqualToString:NUM_ENTRY]) {
        if ( _currentStringValue ) {
            int numEntry = [_currentStringValue intValue];
            self.wifiLists = [[NSMutableArray alloc] initWithCapacity:numEntry];
        }
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY]) {
        if ( _wifiLists && _currentEntry ) {
            [_wifiLists addObject:_currentEntry];
        }
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_SSID]) {
        if ( _currentEntry ) {
            _currentEntry.ssidWithQuotes = _currentStringValue;
        }
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_BSSID]) {
        if ( _currentEntry ) {
            _currentEntry.bssid = _currentStringValue;
        }
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_AUTH_MODE])
    {
        if ( _currentEntry ) {
            if ( !_currentStringValue || [_currentStringValue isEqualToString:@"OPEN"]) {
                _currentEntry.authMode = @"open";
            }
            else if ([_currentStringValue hasPrefix:@"WPA"]) {
                _currentEntry.authMode = @"wpa";
            }
            else if ([_currentStringValue hasPrefix:@"WEP"]) {
                _currentEntry.authMode = @"wep";
            }
            else if ([_currentStringValue isEqualToString:@"SHARED"]) {
                _currentEntry.authMode = @"shared";
            }
        }
    }
    
    if ([elementName isEqualToString:WIFI_ENTRY_QUALITY]) {
        if ( _currentEntry ) {
            if ( _currentStringValue ) {
                _currentEntry.quality = _currentStringValue;
            }
        }
    }

    /*
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
    */

    //reset for the next element
    self.currentStringValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!_currentStringValue) {
        // currentStringValue is an NSMutableString instance variable
        self.currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    [_currentStringValue appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if ( _callback ) {
        [_caller performSelector:_callback withObject:_wifiLists];
    }
}

- (BOOL)checkStatusParserXML
{
    return self.isErrorParser;
}

@end
