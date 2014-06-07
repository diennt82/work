//
//  NotifViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "NotifViewController.h"
#import "PlaybackViewController.h"
#import "PlaylistInfo.h"

@interface NotifViewController ()

@property (retain, nonatomic) IBOutlet UIImageView *imageViewSnapshot;
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *playEnventBtn;
@property (retain, nonatomic) IBOutlet UIButton *goToCameraBtn;
@property (retain, nonatomic) IBOutlet UIButton *changeSettingsBtn;
@property (retain, nonatomic) IBOutlet UILabel *lblChangeSetting;
@property (retain, nonatomic) IBOutlet UIButton *ignoreBtn;
@property (retain, nonatomic) IBOutlet UIButton *choosePlanBtn;
@property (retain, nonatomic) IBOutlet UIButton *learnMoreBtn;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorViewLoading;
@property (retain, nonatomic) IBOutlet UIView *viewFront;
@property (retain, nonatomic) IBOutlet UIView *viewBehide;

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
    
    //[self layoutImageAndTextForButton:self.playEnventBtn];
    
    
    [self.goToCameraBtn setImage:[UIImage imageNamed:@"alert_camera"] forState:UIControlStateNormal];
    [self.goToCameraBtn setImage:[UIImage imageNamed:@"alert_camera_pressed"] forState:UIControlEventTouchDown];
    
    //[self layoutImageAndTextForButton:self.goToCameraBtn];
    
    [self.changeSettingsBtn setImage:[UIImage imageNamed:@"alert_settings"] forState:UIControlStateNormal];
    [self.changeSettingsBtn setImage:[UIImage imageNamed:@"alert_settings_pressed"] forState:UIControlEventTouchDown];
    
    //[self layoutImageAndTextForButton:self.changeSettingsBtn];
    
    [self.choosePlanBtn setImage:[UIImage imageNamed:@"alert_upgrade"] forState:UIControlStateNormal];
    [self.choosePlanBtn setImage:[UIImage imageNamed:@"alert_upgrade_pressed"] forState:UIControlEventTouchDown];
    
    //[self layoutImageAndTextForButton:self.choosePlanBtn];
    
    [self.learnMoreBtn setImage:[UIImage imageNamed:@"alert_learn"] forState:UIControlStateNormal];
    [self.learnMoreBtn setImage:[UIImage imageNamed:@"alert_learn_pressed"] forState:UIControlEventTouchDown];
    
    //[self layoutImageAndTextForButton:self.learnMoreBtn];
    
    self.isFreeUser = NO; // Registered User
    [_playEnventBtn setEnabled:NO];
    
    jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                     Selector:nil
                                                 FailSelector:nil
                                                    ServerErr:nil];
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *eventDate = [dateFormater dateFromString:self.alertTime]; //2013-12-31 07:38:35 +0000
    [dateFormater release];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone localTimeZone]];
    df_local.dateFormat = @"hh:mm a, dd-MM-yyyy";
    
    self.timeLabel.text = [df_local stringFromDate:eventDate];
    self.messageLabel.text = [NSString stringWithFormat:@"There was some movement at %@.",self.cameraName];
    
    NSLog(@"notif view timelable is %@",self.timeLabel.text); 
    
    if(self.camChannel)
    {
        self.lblChangeSetting.hidden = NO;
        self.changeSettingsBtn.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
//	NSArray *viewControllers = self.navigationController.viewControllers;
//	if ([viewControllers indexOfObject:self] == NSNotFound) {
//		// View is disappearing because it was popped from the stack
//		NSLog(@"View controller was popped --- We are closing down..go back to cam list");
//        
//        [self ignoreTouchAction:nil];
//        
//	}
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    _isBackgroundTaskRunning = YES;
    
    if (_eventsListAlready == FALSE)
    {
        //load events from server
        // 1. Load latest snapshot event & events list
        [self performSelectorInBackground:@selector(getEventSnapshot_bg) withObject:nil];
        self.eventsListAlready = TRUE;
    }
    else
    {
        //do nothing
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

- (void)showDialogToConfirm
{
    NSString * msg = [NSString stringWithFormat:@"Video clip is not ready, please try again later."];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
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
                clipInfo.mac_addr = _cameraMacNoColon;
                clipInfo.alertType = _alertType;
                clipInfo.alertVal = _alertVal;
                clipInfo.registrationID = _registrationID;
                
                PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
                
                playbackViewController.clip_info = clipInfo;
                [clipInfo release];
                // Pass the selected object to the new view controller.
                
                NSLog(@"Push the view controller.- %@", self.parentViewController);
                
                [self.navigationController pushViewController:playbackViewController animated:YES];
                [playbackViewController release];
                
                
//                [self dismissViewControllerAnimated:YES
//                                         completion:^{
//                                             
//                                             [_notifDelegate sendStatus:SHOW_CAMERA_LIST];
//                                             [(UIViewController*)_notifDelegate presentViewController:playbackViewController
//                                                                                             animated:NO
//                                                                                           completion:nil];
//                                         }];
                
                
           
            }
            else
            {
                NSLog(@"URL file is not correct");
                [self showDialogToConfirm];
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
        self.viewFront.hidden = YES;
        
        self.viewBehide.hidden = NO;
    }
}

- (IBAction)goToCameraTouchAction:(id)sender
{
    [self cancelTaskDoInBackground];
    
    
    
    
    if (sender == self.goToCameraBtn)
    {
    
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.registrationID forKey:REG_ID];
        [userDefaults synchronize];
        
        // Will call dismiss eventually
        
        if (![self.presentedViewController isBeingDismissed])
        {
            [self dismissViewControllerAnimated:YES completion:^{
                //[_notifDelegate sendStatus:SCAN_BONJOUR_CAMERA];
                [_notifDelegate sendStatus:SHOW_CAMERA_LIST];
            }];
        }
        
        
    }
}

- (IBAction)changeSettingsTouchAction:(id)sender
{
    [self cancelTaskDoInBackground];
    
    CameraMenuViewController *cameraMenuCV = [[CameraMenuViewController alloc] init];
    cameraMenuCV.camChannel = self.camChannel;
    if(self.parentVC)
    {
        MenuViewController *menuVC = (MenuViewController *)self.parentVC;
        cameraMenuCV.cameraMenuDelegate = menuVC.menuDelegate;
    }
    else if(self.notifDelegate)
    {
        cameraMenuCV.cameraMenuDelegate = self.notifDelegate;
    }
    [self.navigationController pushViewController:cameraMenuCV animated:YES];
    [cameraMenuCV release];
}

- (IBAction)choosePlanTouchAction:(id)sender
{
    [self cancelTaskDoInBackground];
}

- (IBAction)leranMoreTouchAction:(id)sender
{
    [self cancelTaskDoInBackground];
}

- (IBAction)ignoreTouchAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // Will call dismiss eventually
    
    if (![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{
            //[_notifDelegate sendStatus:SCAN_BONJOUR_CAMERA];
            [_notifDelegate sendStatus:SHOW_CAMERA_LIST2];
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
    // eventcode: 44334C7FA03C_04_20140310101412000
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSString *alertsString = @"1,2,3,4";
    alertsString = [self urlEncodeUsingEncoding:NSUTF8StringEncoding forString:alertsString];
    
    NSString *event_timecode = [NSString stringWithFormat:@"%@_0%@_%@", self.cameraMacNoColon, self.alertType, self.alertVal];
    NSDictionary *responseDict = [jsonComm getListOfEventsBlockedWithRegisterId:_registrationID
                                                                beforeStartTime:nil//@"2013-12-28 20:10:18"
                                                                      eventCode:event_timecode//event_code // temp
                                                                         alerts:nil
                                                                           page:nil
                                                                         offset:nil
                                                                           size:nil
                                                                         apiKey:apiKey];
    
    NSLog(@"Notif - responseDict: %@", responseDict);
    
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
                        self.alertTime = [event objectForKey:@"time_stamp"];
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
                                                                          waitUntilDone:YES];
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
    
    
    NSString *urlFile = [[_clipsInEvent objectAtIndex:0] objectForKey:@"file"];
    
    if (([urlFile isEqual:[NSNull null]] ||
         [urlFile isEqualToString:@""] || urlFile == nil) && _isBackgroundTaskRunning)
    {
        [self performSelectorInBackground:@selector(getEventSnapshot_bg) withObject:nil];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cancelTaskDoInBackground];
            NSLog(@"url is %@", urlFile);
            [_playEnventBtn setEnabled:YES];
        });
    }
    
}

- (void)cancelTaskDoInBackground
{
    _isBackgroundTaskRunning = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getEventSnapshot_bg) object:nil];
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
    [_viewFront release];
    [_viewBehide release];
    [jsonComm release];
    [super dealloc];
}
@end
