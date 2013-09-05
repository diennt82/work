//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "H264PlayerViewController.h"
#include "mediaplayer.h"

@interface H264PlayerViewController ()
{
    MediaPlayer* mp;
}

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
	[self checkOrientation];
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
    
    [self performSelector:@selector(startStream)
               withObject:nil
               afterDelay:0.1];
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

#pragma mark - Rotation screen
-(void) checkOrientation
{
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
}

- (BOOL)shouldAutorotate
{
    NSLog(@"Should Auto Rotate");
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.progressView.hidden = NO;
    [self stopStream];
    [self adjustViewsForOrientation:toInterfaceOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{ 
        [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land"
                                      owner:self
                                    options:nil];
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController"
                                      owner:self
                                    options:nil];
	}
    
    [self checkIphone5Size:orientation];
    
	self.cameraNameBarBtnItem.title = self.selectedChannel.profile.name;
    
	//set Button handler
	self.backBarBtnItem.target = self;
	self.backBarBtnItem.action = @selector(goBackToCameraList);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame]; // Get status bar frame dimensions
    NSLog(@"1 Statusbar frame: %1.0f, %1.0f, %1.0f, %1.0f", rect.origin.x,
          rect.origin.y, rect.size.width, rect.size.height);
    //HACK : incase hotspot is turned on
    if (rect.size.height>21 &&  rect.size.height<50)
    {
        self.topToolbar.frame = CGRectMake(self.topToolbar.frame.origin.x,self.topToolbar.frame.origin.y+20,
                                      self.topToolbar.frame.size.width, self.topToolbar.frame.size.height);
    }
    else
    {
        if (rect.size.height == 568) // IPHONE5 width
        {
            self.topToolbar.frame = CGRectMake(0,0,
                                          self.topToolbar.frame.size.width, self.topToolbar.frame.size.height);
        }
        else
        {
            
            self.topToolbar.frame = CGRectMake(0,0,
                                          self.topToolbar.frame.size.width, self.topToolbar.frame.size.height);
            
        }
        
    }
    
    [self performSelector:@selector(startStream)
               withObject:nil
               afterDelay:0.1];
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
        else if  (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            
            NSLog(@"iphone5 SHift down...");
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0, 44);
            self.imageViewVideo.transform =translate;
            
            self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, self.progressView.frame.size.width, self.progressView.frame.size.height + 108);
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
