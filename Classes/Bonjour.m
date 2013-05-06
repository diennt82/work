//
//  Bonjour.m
//  MBP_ios
//
//  Created by nxcomm on 06/05/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Bonjour.h"
#define DOMAINS @"local"
#define SERVICE @"_camera._tcp"

@interface Bonjour ()
@end

@implementation Bonjour

@synthesize isSearching;
@synthesize timer;
@synthesize delegate;
@synthesize serviceArray;
@synthesize cameraList;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    isSearching = NO;
    
    if (self.serviceArray == nil)
    {
        self.serviceArray = [[NSMutableArray alloc] init];
    }
    
    if (!_browserService)
    {
        _browserService = [[NSNetServiceBrowser alloc]init];
        [_browserService setDelegate:self];
    }
    
    if (self.cameraList)
    {
        self.cameraList = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void) startScanLocalWiFi
{
    [_browserService searchForServicesOfType:SERVICE inDomain:DOMAINS];
}

#pragma mark -
#pragma mark NSNetServiceDelegate
-(void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    isSearching = YES;
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.serviceArray addObject:aNetService];
    
    if (!moreComing)
    {
        isSearching = NO;
    }
}

-(void) netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    isSearching = NO;
    [self resolveCameraList];
}

-(void) resolveCameraList
{
    for (NSNetService * aNetService in serviceArray)
    {
        @synchronized(self)
        {
            _currentService = aNetService;
            [aNetService setDelegate:self];
            [aNetService resolveWithTimeout:0.0];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:nil userInfo:aNetService repeats:NO];
        }
    }
}
#pragma mark -
#pragma mark NSNetResolveDelegate
- (void)netServiceDidResolveAddress:(NSNetService *)service {
	assert(service == _currentService);
	
	[service retain];
	[self stopCurrentResolve];
    
    NSString * serviceName;
    NSString * ip_address;
    for (NSData *address in [service addresses])
    {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        NSLog(@"Service name: %@ , ip: %s , port %i", [service name], inet_ntoa(socketAddress->sin_addr), [service port]);
        serviceName = [service name];
        ip_address = inet_ntoa(socketAddress->sin_addr);
    }
    
    NSDictionary * dict = [[NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]] retain];
    
	NSString * macAddress = [self decodeHexToString:[dict objectForKey:@"mac"]];
    
    NSLog(@"Mac ----------> %@", [self decodeHexToString:@"<34383032 32613263 61633331>"]);
    
    NSDictionary * cameraInfo = [[NSDictionary alloc]initWithObjectsAndKeys:serviceName,@"seviceName",ip_address,@"ip_address",macAddress,@"macAddress", nil];
    
    [self.cameraList addEntriesFromDictionary:cameraInfo];
    [self.delegate bonjourReturnCameraList:cameraList];
    [cameraInfo release];
    [dict release];
	[service release];
}

-(NSString *) decodeHexToString:(NSString *) string
{
    NSString * newString1 = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * newString2 = [newString1 stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSString * finalString = [newString2 stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSMutableString * newString = [[[NSMutableString alloc] init] autorelease];
    int i = 0;
    while (i < [finalString length])
    {
        NSString * hexChar = [finalString substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
    
    return newString;
}

- (NSString *)copyStringFromTXTDict:(NSDictionary *)dict which:(NSString*)which
{
	// Helper for getting information from the TXT data
	NSData* data = [dict objectForKey:which];
	NSString *resultString = nil;
	if (data) {
		resultString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	}
	return resultString;
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    
    
}

- (void)stopCurrentResolve {
    //	self.needsActivityIndicator = NO;
	self.timer = nil;
    
	[_currentService stop];
	_currentService = nil;
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [timer release];
    delegate = nil;
    [serviceArray removeAllObjects];
    [super dealloc];
}
@end
