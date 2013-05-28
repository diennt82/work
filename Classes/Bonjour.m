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
@synthesize bonjourStatus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        bonjourStatus = BONJOUR_STATUS_DEFAULT;
    }
    
    
    return self;
}

-(void) initSetupWith:(NSMutableArray *) cameras
{
    _cameras = cameras;
    bonjourStatus = BONJOUR_STATUS_DEFAULT;
    
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

-(void) stopScanLocalWiFi
{
    [_browserService stop];
}

#pragma mark -
#pragma mark NSNetServiceDelegate
-(void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    isSearching = YES;
    bonjourStatus = BONJOUR_STATUS_DEFAULT;
    [serviceArray removeAllObjects];
    if (timer)
    {
        [timer invalidate];
        self.timer = nil;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(stopScanLocalWiFi) userInfo:nil repeats:NO];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.serviceArray addObject:aNetService];
    
    if (!moreComing)
    {
        isSearching = NO;
        bonjourStatus = BONJOUR_STATUS_OK;
//        [self resolveCameraList];
    }
}

-(void) netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    isSearching = NO;
    
    if ([serviceArray count] == 0)
    {
        bonjourStatus = BONJOUR_STATUS_TIMEOUT;
        
        [self.delegate bonjourReturnCameraListAvailable:self.cameraList];
    }
    else
    {
        bonjourStatus = BONJOUR_STATUS_OK;
        [self resolveCameraList];
    }
    NSLog(@"Number of Services is : %i",[serviceArray count]);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    bonjourStatus = BONJOUR_STATUS_ERROR;
    NSLog(@"error : %@", errorDict.description);
    
    [self.delegate bonjourReturnCameraListAvailable:cameraList];
}

-(void) resolveCameraList
{
    if ([serviceArray count] == 0)
    {
        return;
    }
    
    nextIndex = 0;
    _lastService = [serviceArray lastObject];
    
    NSNetService * aNetService = [serviceArray objectAtIndex:nextIndex];
    [aNetService setDelegate:self];
    [aNetService resolveWithTimeout:0.0];
    
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
    
    for (CamProfile * cam_profile in _cameras)
    {
        if ([self isCameraIP:ip availableWith:macString] &&
            [cam_profile.mac_address isEqualToString:macString])
        {
            [self.cameraList addObject:cam_profile];
        }
    }
    
    if (service == _lastService)
    {
        [self.delegate bonjourReturnCameraListAvailable:self.cameraList];
    }
    else
    {
        nextIndex += 1;
        NSNetService * nextService = [serviceArray objectAtIndex:nextIndex];
            [nextService setDelegate:self];
            [nextService resolveWithTimeout:0.0];
    }
    
    [ip release];
    [strMac release];
}


// Not use
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
    
    HttpCommunication * dev_com = [[HttpCommunication alloc] init];
    
    dev_com.device_ip = ip;
    
    NSString * mac = [dev_com sendCommandAndBlock:GET_MAC_ADDRESS withTimeout:5.0];
    
    if (mac != nil && mac.length == 12)
    {
        mac = [Util add_colon_to_mac:mac];
        
        
        if([mac isEqualToString:macAddress])
        {
            return YES;
        }
    }

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
    [_cameras release];
    [_lastService release];
    [_browserService release];
    [camera_profiles release];
    [cameraList release];
    [timer invalidate];
    self.timer = nil;
    delegate = nil;
    [serviceArray removeAllObjects];
    [super dealloc];
}
@end
