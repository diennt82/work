//
//  NotifViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "NotifViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "PlaybackViewController.h"
#import "PlaylistInfo.h"

@interface NotifViewController ()

@property (retain, nonatomic) IBOutlet UIImageView *imageViewSnapshot;
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *playEnventBtn;
@property (retain, nonatomic) IBOutlet UIButton *goToCameraBtn;
@property (retain, nonatomic) IBOutlet UIButton *changeSettingsBtn;
@property (retain, nonatomic) IBOutlet UIButton *ignoreBtn;
@property (retain, nonatomic) IBOutlet UIButton *choosePlanBtn;
@property (retain, nonatomic) IBOutlet UIButton *learnMoreBtn;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorViewLoading;

@property (nonatomic) BOOL eventsListAlready;
@property (nonatomic, retain) NSDictionary *event;
@property (nonatomic, retain) NSMutableArray *clipsInEvent;
@property (nonatomic) BOOL isFreeUser;

@end

@implementation NotifViewController

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
    
    [self.playEnventBtn setImage:[UIImage imageNamed:@"alert_play"] forState:UIControlStateNormal];
    [self.playEnventBtn setImage:[UIImage imageNamed:@"alert_play_pressed"] forState:UIControlEventTouchDown];
    
    [self layoutImageAndTextForButton:self.playEnventBtn];
    
    
    [self.goToCameraBtn setImage:[UIImage imageNamed:@"alert_camera"] forState:UIControlStateNormal];
    [self.goToCameraBtn setImage:[UIImage imageNamed:@"alert_camera_pressed"] forState:UIControlEventTouchDown];
    
    [self layoutImageAndTextForButton:self.goToCameraBtn];
    
    [self.changeSettingsBtn setImage:[UIImage imageNamed:@"alert_settings"] forState:UIControlStateNormal];
    [self.changeSettingsBtn setImage:[UIImage imageNamed:@"alert_settings_pressed"] forState:UIControlEventTouchDown];
    
    [self layoutImageAndTextForButton:self.changeSettingsBtn];
    
    [self.choosePlanBtn setImage:[UIImage imageNamed:@"alert_upgrade"] forState:UIControlStateNormal];
    [self.choosePlanBtn setImage:[UIImage imageNamed:@"alert_upgrade_pressed"] forState:UIControlEventTouchDown];
    
    [self layoutImageAndTextForButton:self.choosePlanBtn];
    
    [self.learnMoreBtn setImage:[UIImage imageNamed:@"alert_learn"] forState:UIControlStateNormal];
    [self.learnMoreBtn setImage:[UIImage imageNamed:@"alert_learn_pressed"] forState:UIControlEventTouchDown];
    
    [self layoutImageAndTextForButton:self.learnMoreBtn];
    
    self.isFreeUser = NO; // Registered User
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if (_eventsListAlready == FALSE)
    {
        //load events from server
        // 1. Load latest snapshot event & events list
        [self performSelectorInBackground:@selector(getEventSnapshot_bg) withObject:nil];
        
        self.eventsListAlready = TRUE;
    }
    else
    {
        //
    }
}

- (void)layoutImageAndTextForButton: (UIButton *)button
{
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.frame.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = button.titleLabel.frame.size;
    button.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}

#pragma mark - Action

- (IBAction)playEventTouchAction:(id)sender
{
    if (!_isFreeUser)
    {
        if (![_clipsInEvent isEqual:[NSNull null]] &&
            _clipsInEvent.count > 0)
        {
            NSString *urlFile = [[_clipsInEvent objectAtIndex:0] objectForKey:@"file"];
            
            if (![urlFile isEqual:[NSNull null]] &&
                ![urlFile isEqualToString:@""])
            {
                PlaylistInfo *clipInfo = [[PlaylistInfo alloc] init];
                clipInfo.urlFile = urlFile;
                
                PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
                
                playbackViewController.clip_info = clipInfo;
                playbackViewController.clipsInEvent = [NSMutableArray arrayWithArray:_clipsInEvent];
                // Pass the selected object to the new view controller.
                
                NSLog(@"Push the view controller.- %@", self.parentViewController);
                
                [self.navigationController pushViewController:playbackViewController animated:YES];
                [playbackViewController release];
            }
            else
            {
                NSLog(@"URL file is not correct");
            }
        }
        else
        {
            NSLog(@"There was no clip in event");
        }
    }
    else
    {
        self.messageLabel.text = @"You do not have motion detected recording enabled. Please choose an option below";
        self.timeLabel.hidden = YES;
        self.playEnventBtn.hidden = YES;
        self.goToCameraBtn.hidden = YES;
        self.changeSettingsBtn.hidden = YES;
        
        self.choosePlanBtn.hidden = NO;
        self.learnMoreBtn.hidden = NO;
    }
}

- (IBAction)goToCameraTouchAction:(id)sender
{
    if (sender == self.goToCameraBtn)
    {
        //[self.navigationController popToRootViewControllerAnimated:NO];
        
        // Will call dismiss eventually
        
        if (![self.presentedViewController isBeingDismissed]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [_notifDelegate sendStatus:SCAN_BONJOUR_CAMERA];
            }];
        }
        
        
    }
}

- (IBAction)changeSettingsTouchAction:(id)sender
{
}

- (IBAction)choosePlanTouchAction:(id)sender
{
}

- (IBAction)leranMoreTouchAction:(id)sender
{
}

- (IBAction)ignoreTouchAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // Will call dismiss eventually
    
    if (![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [_notifDelegate sendStatus:SCAN_BONJOUR_CAMERA];
        }];
    }
}

#pragma mark - Encoding URL string

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding forString: (NSString *)aString {
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)aString,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@=+$,?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding));
}

#pragma mark - Methods

- (void)getEventSnapshot_bg
{
    //2013-12-20 20:10:18 (yyyy-MM-dd HH:mm:ss).
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSString *alertsString = @"1,2,3,4";
    alertsString = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:alertsString];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];

    NSDictionary *responseDict = [jsonComm getListOfEventsBlockedWithRegisterId:_registrationID
                                                                beforeStartTime:nil//@"2013-12-28 20:10:18"
                                                                      eventCode:nil//event_code // temp
                                                                         alerts:alertsString
                                                                           page:nil
                                                                         offset:nil
                                                                           size:nil
                                                                         apiKey:apiKey];
    [jsonComm release];
    
    //NSLog(@"Notif - responseDict: %@", responseDict);
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            //4 44334C31A004 20130914055827490 2013-09-14T05:59:05+00:00 Camera-31a004
            
            // work
            NSMutableArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            if (events != nil &&
                events.count > 0)
            {
                for (NSDictionary *event in events)
                {
                    //if ([[event objectForKey:@"value"] isEqual:_alertVal])
                    if ([[NSString stringWithFormat:@"%@", [event objectForKey:@"value"]] isEqualToString:_alertVal])
                    {
                        // This is the event. Get clips in this event
                        self.clipsInEvent = [event objectForKey:@"data"];
                        self.event = event;
                        
                        if (![_clipsInEvent isEqual:[NSNull null]] &&
                            _clipsInEvent.count > 0)
                        {
                            // Get snapshot of event
                            NSString *urlImgString = [[_clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                            
                            if (![urlImgString isEqual:[NSNull null]]
                                && ![urlImgString isEqualToString:@""])
                            {
                                UIImage *tmpImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImgString]]];
                                
                                if (tmpImage != NULL)
                                {
                                    [self.imageViewSnapshot performSelectorOnMainThread:@selector(setImage:)
                                                                             withObject:tmpImage
                                                                          waitUntilDone:NO];
                                }
                            }
                            
                            else
                            {
                                NSLog(@"Image snapshot url is null. Use default");
                            }
                        }
                        else
                        {
                            NSLog(@"Event has no data");
                        }
                        
                        break;
                    }
                }    
            }
            else
            {
                NSLog(@"Events empty!");
            }
        }
        else
        {
            NSLog(@"Response status != 200");
        }
    }
    else
    {
        NSLog(@"responseDict is nil");
    }
    
    [self.activityIndicatorViewLoading stopAnimating];
    
    if (_imageViewSnapshot.image == nil) // No snapshot image from server
    {
        [self.imageViewSnapshot performSelectorOnMainThread:@selector(setImage:)
                                                 withObject:[UIImage imageNamed:@"loading_logo.png"]
                                              waitUntilDone:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_playEnventBtn release];
    [_goToCameraBtn release];
    [_changeSettingsBtn release];
    [_ignoreBtn release];
    [_choosePlanBtn release];
    [_learnMoreBtn release];
    [_messageLabel release];
    [_timeLabel release];
    [_imageViewSnapshot release];
    [_activityIndicatorViewLoading release];
    [super dealloc];
}
@end
