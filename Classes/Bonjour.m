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

-(id) initwithCamProfiles:(NSMutableArray *) camera_profiles
{
    self = [super init];
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
    
    if (!self.cameraList)
    {
        self.cameraList = [[NSMutableArray alloc] init];
    }
    
    if (self.camera_profiles == nil)
    {
        self.camera_profiles = [[NSMutableArray alloc] init];
    }
    
    self.camera_profiles = camera_profiles;
    
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
    if (!serviceArray)
    {
        return;
    }
    
    _lastService = [serviceArray lastObject];
    
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
	
	[service retain];
    
    NSString * serviceName;
    char * ip_address;
    for (NSData *address in [service addresses])
    {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        serviceName = [service name];
        ip_address = inet_ntoa(socketAddress->sin_addr);
    }
    
    NSDictionary * dict = [[NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]] retain];
    
	NSData * macAddress = [dict objectForKey:@"mac"];
    
    NSString * strMac = [[NSString alloc] initWithData:macAddress encoding:NSASCIIStringEncoding];
    
//    NSString * ip = [NSString stringWithFormat:@"%s",ip_address];
    
    strMac = [Util add_colon_to_mac:strMac];
    
    for (CamProfile * cam_profile in camera_profiles)
    {
        if ([strMac isEqualToString:cam_profile.mac_address])
        {
            [self.cameraList addObject:cam_profile];
        }
    }
    
    if (service == _lastService)
    {
        [self.delegate bonjourReturnCameraListAvailable:self.cameraList];
    }
    
    [strMac release];
    [dict release];
	[service release];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [camera_profiles release];
    [cameraList release];
    [timer release];
    delegate = nil;
    [serviceArray removeAllObjects];
    [super dealloc];
}
@end
