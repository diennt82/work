//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "H264PlayerViewController.h"
#include "mediaplayer.h"
#import "HttpCommunication.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface H264PlayerViewController ()
{
    MediaPlayer* mp;
}

@property (nonatomic, retain) HttpCommunication* httpComm;

@end

@implementation H264PlayerViewController

#pragma mark - View
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.stream_url = [NSString stringWithFormat:@"rtsp://user:pass@%@:6667/blinkhd", self.selectedChannel.profile.ip_address];
    
    NSLog(@"stream_url = %@", self.stream_url);
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                       @"Back", nil);
	self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:msg
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    [self becomeActive];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - Method

- (void)becomeActive
{
    CamProfile *cp = self.selectedChannel.profile;
    
    //Set camera name
    self.cameraNameBarBtnItem.title = cp.name;
    
    //set Button handler
    self.backBarBtnItem.target = self;
    self.backBarBtnItem.action = @selector(goBackToCameraList);
    
    self.progressView.hidden = NO;
    [self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
//    [self performSelector:@selector(startStream)
//               withObject:nil
//               afterDelay:0.1];
    [self setupCamera];
}

- (void)setupCamera
{
    if (self.httpComm != nil)
    {
        [self.httpComm release];
        self.httpComm = nil;
    }
    
    self.httpComm = [[HttpCommunication alloc]init];
    self.httpComm.device_ip = self.selectedChannel.profile.ip_address;
    self.httpComm.device_port = self.selectedChannel.profile.port;
    
    //Support remote UPNP video as well
    if (self.selectedChannel.profile.isInLocal == TRUE)
    {
        NSLog(@"created a local streamer");
        self.stream_url = [NSString stringWithFormat:@"rtsp://user:pass@%@:6667/blinkhd", self.selectedChannel.profile.ip_address];
        
        [self performSelector:@selector(startStream)
                   withObject:nil
                   afterDelay:0.1];
    }
    else
    {
        NSLog(@"created a remote streamer");
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                                 Selector:@selector(createSesseionSuccessWithResponse:)
                                                                             FailSelector:@selector(createSessionFailedWithResponse:)
                                                                                ServerErr:@selector(createSessionFailedUnreachableSerever)];
        [jsonComm createSessionWithRegistrationId:mac
                                    andClientType:@"IOS"
                                        andApiKey:apiKey];
//        NSDictionary *responseDict = [jsonComm createSessionBlockedWithRegistrationId:mac
//                                                                        andClientType: @"IOS"
//                                                                            andApiKey:apiKey];
        
        //self.stream_url = @"rtmp://";
    }
}

-(void) startStream
{
    self.progressView.hidden = YES;
    status_t status;

    mp = new MediaPlayer();
    
    NSString * url =@"http://192.168.3.116:6667/blinkhd";
    
    url = _stream_url;
    
    
    status = mp->setDataSource([url UTF8String]);
    printf("setDataSource return: %d\n", status);
    
    
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("setDataSource error: %d\n", status);
        return;
    }
    
    CGRect rect = CGRectMake(self.imageViewVideo.frame.origin.x, self.imageViewVideo.frame.origin.y, mp->getVideoWidth(0), mp->getVideoHeight(0));
    
    NSLog(@"rect = %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    mp->setVideoSurface(self.imageViewVideo);
    
    NSLog(@"Prepare the player");
    
    status=  mp->prepare();
    
    printf("prepare return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("prepare() error: %d\n", status);
        exit(1);
    }
    
    // Play anyhow
    
    status=  mp->start();
    
    printf("start() return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("start() error: %d\n", status);
        return;
    }
}

- (void)goBackToCameraList
{
    [self stopStream];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)stopStream
{
    printf("STOP\n");
    if (mp->isPlaying())
    {
        mp->suspend();
        mp->stop();
    }
    free(mp);
    mp = NULL;
}

#pragma mark - JSON Callback

- (void)createSesseionSuccessWithResponse: (NSDictionary *)responseDict
{
    if (responseDict) {
        if ([[responseDict objectForKey:@"status"] intValue] == 200) {
            self.stream_url = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
            
            [self performSelector:@selector(startStream)
                       withObject:nil
                       afterDelay:0.1];
        }
    }
    NSLog(@"createSesseionSuccess");
}

- (void)createSessionFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"createSessionFailedWith code %d", [[responseDict objectForKey:@"status"] intValue]);
}

- (void)createSessionFailedUnreachableSerever
{
    NSLog(@"createSessionFailedUnreachableSerever");
}

#pragma mark - Rotation screen
- (BOOL)shouldAutorotate
{
    NSLog(@"Should Auto Rotate");
	return NO;
}

- (void) checkIphone5Size: (UIInterfaceOrientation)orientation
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568)
    {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            NSLog(@"iphone5 SHift right...");
            CGAffineTransform translate = CGAffineTransformMakeTranslation(44, 0);
            self.imageViewVideo.transform = translate;
            
            self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, self.progressView.frame.size.width + 88, self.progressView.frame.size.height);
        }
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.stream_url release];
    [_imageViewVideo release];
    [_topToolbar release];
    [_backBarBtnItem release];
    [_progressView release];
    [_cameraNameBarBtnItem release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setImageViewVideo:nil];
    [self setTopToolbar:nil];
    [self setBackBarBtnItem:nil];
    [self setProgressView:nil];
    [self setCameraNameBarBtnItem:nil];
    [super viewDidUnload];
}
@end
