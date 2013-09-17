//
//  PlaybackViewController.m
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "PlaybackViewController.h"
#import <H264MediaPlayer/H264MediaPlayer.h>


@interface PlaybackViewController ()
{
    MediaPlayer *mp;
}

@property (retain, nonatomic) IBOutlet UIImageView *imageVideo;
@property (retain, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *backBarBtnItem;
@property (retain, nonatomic) IBOutlet UIView *progressView;

@end

@implementation PlaybackViewController

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
    
    self.progressView.hidden = NO;
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                       @"Back", nil);
	self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:msg
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    [self becomeActive];
}

- (void)becomeActive
{
    //CamProfile *cp = self.selectedChannel.profile;
    
    //Set camera name
    //self.cameraNameBarBtnItem.title = cp.name;
    
    //set Button handler
    self.backBarBtnItem.target = self;
    self.backBarBtnItem.action = @selector(goBackToPlayList);
    
    //self.progressView.hidden = YES;
    [self performSelector:@selector(startStream)
               withObject:nil
               afterDelay:0.1];
}

#pragma mark - Play Video

-(void) startStream
{
    //self.progressView.hidden = YES;
    
    status_t status;
    
    mp = new MediaPlayer(true);
    
    NSString * url =@"http://192.168.3.116:6667/blinkhd";
    
    url = self.urlVideo;
    
    
    status = mp->setDataSource([url UTF8String]);
    printf("setDataSource return: %d\n", status);
    
    
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("setDataSource error: %d\n", status);
        return;
    }

    mp->setVideoSurface(self.imageVideo);
    
    NSLog(@"Prepare the player");
    
    status=  mp->prepare();
    
    printf("prepare return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("prepare() error: %d\n", status);
        exit(1);
    }
    
    self.progressView.hidden = YES;
    // Play anyhow
    
    status=  mp->start();
    
    printf("start() return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("start() error: %d\n", status);
        return;
    }
    
    self.progressView.hidden = YES;
}

- (void)goBackToPlayList
{
    if (mp) {
        [self stopStream];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_imageVideo release];
    [_topToolbar release];
    [_backBarBtnItem release];
    [_progressView release];
    
    [_urlVideo release];
    
    [super dealloc];
}
- (void)viewDidUnload {
    [self setImageVideo:nil];
    [self setTopToolbar:nil];
    [self setBackBarBtnItem:nil];
    [self setProgressView:nil];
    
    [self setUrlVideo:nil];
    
    [super viewDidUnload];
}
@end
