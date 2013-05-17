//
//  Bonjour.m
//  MBP_ios
//
//  Created by nxcomm on 06/05/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Bonjour.h"
#define DOMAINS @"local"
#define SERVICE @"_camera._tcp."

@interface Bonjour ()
@end

@implementation Bonjour

@synthesize isSearching;
@synthesize timer;
@synthesize delegate;
@synthesize serviceArray;
@synthesize cameraList, camera_profiles;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    
    return self;
}

-(id) initBrowser
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    
    isSearching = NO;
    
    if (!self.serviceArray)
    {
        self.serviceArray = [[NSMutableArray alloc] init];
    }
    
    if (!_browserService)
    {
        _browserService = [[NSNetServiceBrowser alloc]init];
        [_browserService setDelegate:self];
    }
    
    if (!self.cameraList)
    {
        self.cameraList = [[NSMutableArray alloc] init];
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
    if (_browserService)
    {
        [_browserService stop];
        [_browserService setDelegate:self];
    }
    
    [_browserService searchForServicesOfType:SERVICE inDomain:DOMAINS];
}

#pragma mark -
#pragma mark NSNetServiceDelegate
-(void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    isSearching = YES;
    [serviceArray removeAllObjects];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.serviceArray addObject:aNetService];
    
    if (!moreComing)
    {
        isSearching = NO;
        [self resolveCameraList];
    }
}

-(void) netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    isSearching = NO;
    NSLog(@"Number of Services is : %i",[serviceArray count]);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"error : %@", errorDict.description);
}

-(void) resolveCameraList
{
    if ([serviceArray count] == 0)
    {
        return;
    }
    
    _lastService = [serviceArray lastObject];
//    [_browserService stop];
    
    for (NSNetService * aNetService in serviceArray)
    {
            [aNetService setDelegate:self];
            [aNetService resolveWithTimeout:5.0];
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:nil userInfo:aNetService repeats:NO];
    }
}
#pragma mark -
#pragma mark NSNetResolveDelegate
- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    NSDictionary * dict = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
    
	NSData * macAddress = [dict objectForKey:@"mac"];
    
    NSString * strMac = [[NSString alloc] initWithData:macAddress encoding:NSASCIIStringEncoding];
    
    NSData * ipString = [dict objectForKey:@"ip"];
    
    NSString * ip = [[NSString alloc] initWithData:ipString encoding:NSASCIIStringEncoding];
    
    NSString * macString = [Util add_colon_to_mac:strMac];
    
    CamProfile * cam_profile = [[CamProfile alloc] initWithMacAddr:macString];
    [cam_profile setIp_address:ip];
    
//    for (CamProfile * cam_profile in camera_profiles)
//    {
        if ([self isCameraIP:ip availableWith:macString])
        {
            [self.cameraList addObject:cam_profile];
        }
//    }
    
    if (service == _lastService)
    {
        [self.delegate bonjourReturnCameraListAvailable:self.cameraList];
    }
    
    [ip release];
    [strMac release];
}

-(NSData *) getMacCamera:(NSString *) ip_string
{
    NSData * mac;
	NSURLResponse * response;
    NSError* error = nil;
    NSString * httpRequest = [NSString stringWithFormat:@"%@%@%@",
                              @"http://",
                              ip_string,
                              @"/?action=command&command=get_mac_address"];
    
    @synchronized(self)
	{
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:httpRequest]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:3.0];
		
        error = nil;
        mac = [NSURLConnection sendSynchronousRequest:theRequest
                                          returningResponse:&response
                                                      error:&error];
        
	}
    
    if ( (mac == nil) ||  (error != nil))
    {
        return nil;
    }
    else
    {
        return mac;
    }
    
}

- (BOOL) isCameraIP:(NSString *) ip availableWith:(NSString *) macAddress
{
    if (ip == nil || macAddress == nil)
    {
        return  NO;
    }
    
    
    NSData * data = [self getMacCamera:ip];
    if (data == nil)
    {
        return NO;
    }
    
    NSString * macString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSString * mac = [Util add_colon_to_mac:macString];
    
    if ([macAddress isEqualToString:mac])
    {
        [macString release];
        return  YES;
    }
    [macString release];
    return  NO;
}
#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [_lastService release];
    [_browserService release];
    [camera_profiles release];
    [cameraList release];
//    [timer release];
    delegate = nil;
    [serviceArray removeAllObjects];
    [super dealloc];
}
@end
