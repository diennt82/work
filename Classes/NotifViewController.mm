//
//  NotifViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/17/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>

#import "NotifViewController.h"
#import "PlaybackViewController.h"
#import "CameraMenuViewController.h"
#import "MenuViewController.h"
#import "PlaylistInfo.h"

@interface NotifViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageViewSnapshot;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIButton *playEnventBtn;
@property (nonatomic, weak) IBOutlet UIButton *goToCameraBtn;
@property (nonatomic, weak) IBOutlet UIButton *changeSettingsBtn;
@property (nonatomic, weak) IBOutlet UILabel *lblChangeSetting;
@property (nonatomic, weak) IBOutlet UIButton *ignoreBtn;
@property (nonatomic, weak) IBOutlet UIButton *choosePlanBtn;
@property (nonatomic, weak) IBOutlet UIButton *learnMoreBtn;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorViewLoading;
@property (nonatomic, weak) IBOutlet UIView *viewFront;
@property (nonatomic, weak) IBOutlet UIView *viewBehide;

@property (nonatomic, strong) NSDictionary *event;
@property (nonatomic, strong) NSMutableArray *clipsInEvent;
@property (nonatomic, strong) BMS_JSON_Communication *jsonComm;

@property (nonatomic) BOOL isBackgroundTaskRunning;
@property (nonatomic) BOOL eventsListAlready;
@property (nonatomic) BOOL isFreeUser;
@property (nonatomic) BOOL isReturnFrmPlayback;

@end

@implementation NotifViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSBundle mainBundle] loadNibNamed:@"NotifViewController~iPad"
                                      owner:self
                                    options:nil];
    }
    
    [_playEnventBtn setImage:[UIImage imageNamed:@"alert_play"] forState:UIControlStateNormal];
    [_playEnventBtn setImage:[UIImage imageNamed:@"alert_play_pressed"] forState:UIControlEventTouchDown];
    
    //[self layoutImageAndTextForButton:_playEnventBtn];
    
    
    [_goToCameraBtn setImage:[UIImage imageNamed:@"alert_camera"] forState:UIControlStateNormal];
    [_goToCameraBtn setImage:[UIImage imageNamed:@"alert_camera_pressed"] forState:UIControlEventTouchDown];
    
    //[self layoutImageAndTextForButton:_goToCameraBtn];
    
    [_changeSettingsBtn setImage:[UIImage imageNamed:@"alert_settings"] forState:UIControlStateNormal];
    [_changeSettingsBtn setImage:[UIImage imageNamed:@"alert_settings_pressed"] forState:UIControlEventTouchDown];
    
    //[self layoutImageAndTextForButton:_changeSettingsBtn];
    
    [_choosePlanBtn setImage:[UIImage imageNamed:@"alert_upgrade"] forState:UIControlStateNormal];
    [_choosePlanBtn setImage:[UIImage imageNamed:@"alert_upgrade_pressed"] forState:UIControlEventTouchDown];
    
    //[self layoutImageAndTextForButton:_choosePlanBtn];
    
    [_learnMoreBtn setImage:[UIImage imageNamed:@"alert_learn"] forState:UIControlStateNormal];
    [_learnMoreBtn setImage:[UIImage imageNamed:@"alert_learn_pressed"] forState:UIControlEventTouchDown];
    
    //[self layoutImageAndTextForButton:_learnMoreBtn];
    
    self.isFreeUser = NO; // Registered User
    [_playEnventBtn setEnabled:NO];
    _isReturnFrmPlayback = FALSE;
    
    self.jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                          Selector:nil
                                                      FailSelector:nil
                                                         ServerErr:nil];
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *eventDate = [dateFormater dateFromString:_alertTime]; //2013-12-31 07:38:35 +0000
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone localTimeZone]];
    df_local.dateFormat = @"hh:mm a, dd-MM-yyyy";
    
    _timeLabel.text = [df_local stringFromDate:eventDate];
    _messageLabel.text = [NSString stringWithFormat:@"There was some movement at %@.",_cameraName];
    
    NSLog(@"notif view timelable is %@",_timeLabel.text); 
    
    if (_camChannel) {
        _lblChangeSetting.hidden = NO;
        _changeSettingsBtn.hidden = NO;
    }
    
    [self performSelectorInBackground:@selector(getEventSnapshot) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%s _isReturnFrmPlayback:%d", __FUNCTION__, _isReturnFrmPlayback);
    
    self.navigationController.navigationBarHidden = YES;
    
    if (_isReturnFrmPlayback) {
        _isReturnFrmPlayback = NO;
        [self ignoreTouchAction:nil]; // Fake to go to Camera list.
    }
    else {
        _isBackgroundTaskRunning = YES;
    }
    
#if 0
    if (_eventsListAlready == NO) {
        //load events from server
        // 1. Load latest snapshot event & events list
        [self performSelectorInBackground:@selector(getEventSnapshot) withObject:nil];
        self.eventsListAlready = YES;
    }
#endif
}

- (void)layoutImageAndTextForButton: (UIButton *)button
{
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.frame.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = button.titleLabel.frame.size;
    button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, -titleSize.width);
}

- (void)showDialogToConfirm
{
    NSString *msg = [NSString stringWithFormat:@"Video clip is not ready, please try again later."];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Action

- (IBAction)playEventTouchAction:(id)sender
{
    if (!_isFreeUser) {
        if (![_clipsInEvent isEqual:[NSNull null]] && _clipsInEvent.count > 0) {
            NSString *urlFile = [[_clipsInEvent objectAtIndex:0] objectForKey:@"file"];
            
            if (![urlFile isEqual:[NSNull null]] && ![urlFile isEqualToString:@""]) {
                PlaylistInfo *clipInfo = [[PlaylistInfo alloc] init];
                clipInfo.urlFile = urlFile;
                clipInfo.macAddr = _cameraMacNoColon;
                clipInfo.alertType = _alertType;
                clipInfo.alertVal = _alertVal;
                clipInfo.registrationID = _registrationID;
                
                PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] initWithNibName:@"PlaybackViewController" bundle:nil];
                [playbackViewController setClipInfo:clipInfo];
                
                NSLog(@"Push the view controller.- %@", self.parentViewController);
                _isReturnFrmPlayback = TRUE;
                [self.navigationController pushViewController:playbackViewController animated:YES];
            }
            else {
                NSLog(@"URL file is not correct");
                [self showDialogToConfirm];
            }
        }
        else {
            NSLog(@"There was no clip in event");
        }
    }
    else {
        _messageLabel.text = @"You do not have motion detected recording enabled. Please choose an option below";
        _viewFront.hidden = YES;
        _viewBehide.hidden = NO;
    }
}

- (IBAction)goToCameraTouchAction:(id)sender
{
    [self cancelTaskDoInBackground];

    if (sender == _goToCameraBtn) {
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_registrationID forKey:REG_ID];
        [userDefaults synchronize];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        [_notifDelegate sendStatus:SHOW_CAMERA_LIST];
    }
}

- (IBAction)changeSettingsTouchAction:(id)sender
{
    [self cancelTaskDoInBackground];
    
    CameraMenuViewController *cameraMenuCV = [[CameraMenuViewController alloc] initWithNibName:@"CameraMenuViewController" bundle:nil];
    cameraMenuCV.camChannel = _camChannel;
    if (_parentVC) {
        MenuViewController *menuVC = (MenuViewController *)_parentVC;
        cameraMenuCV.cameraMenuDelegate = menuVC.menuDelegate;
    }
    else if (_notifDelegate) {
        cameraMenuCV.cameraMenuDelegate = _notifDelegate;
    }
    [self.navigationController pushViewController:cameraMenuCV animated:YES];
}

- (IBAction)choosePlanTouchAction:(id)sender
{
    [self cancelTaskDoInBackground];
}

- (IBAction)learnMoreTouchAction:(id)sender
{
    [self cancelTaskDoInBackground];
}

- (IBAction)ignoreTouchAction:(id)sender
{
    DLog(@"%s _notifDelegate:%@", __FUNCTION__, _notifDelegate);
    [self cancelTaskDoInBackground];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [_notifDelegate sendStatus:SHOW_CAMERA_LIST];
}

#pragma mark - Methods

- (void)getEventSnapshot
{
    //2013-12-20 20:10:18 (yyyy-MM-dd HH:mm:ss).
    // eventcode: 44334C7FA03C_04_20140310101412000
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *event_timecode = [NSString stringWithFormat:@"%@_0%@_%@", _cameraMacNoColon, _alertType, _alertVal];
    NSDictionary *responseDict = [_jsonComm getListOfEventsBlockedWithRegisterId:_registrationID
                                                                 beforeStartTime:nil//@"2013-12-28 20:10:18"
                                                                       eventCode:event_timecode//event_code // temp
                                                                          alerts:nil
                                                                            page:nil
                                                                          offset:nil
                                                                            size:nil
                                                                          apiKey:apiKey];
    NSLog(@"Notif - responseDict: %@", responseDict);
    
    if ( responseDict ) {
        if ([responseDict[@"status"] integerValue] == 200) {
            //4 44334C31A004 20130914055827490 2013-09-14T05:59:05+00:00 Camera-31a004
            
            // work
            NSMutableArray *events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            if ( events.count > 0 ) {
                for (NSDictionary *event in events) {
                    //if ([[event objectForKey:@"value"] isEqual:_alertVal])
                    if ([[NSString stringWithFormat:@"%@", event[@"value"]] isEqualToString:_alertVal]) {
                        // This is the event. Get clips in this event
                        self.clipsInEvent = event[@"data"];
                        self.alertTime = event[@"time_stamp"];
                        self.event = event;
                        
                        if (![_clipsInEvent isEqual:[NSNull null]] && _clipsInEvent.count > 0) {
                            // Get snapshot of event
                            NSString *urlImgString = [[_clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                            
                            if (![urlImgString isEqual:[NSNull null]] && ![urlImgString isEqualToString:@""]) {
                                UIImage *tmpImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImgString]]];
                                
                                if ( tmpImage ) {
                                    [_imageViewSnapshot performSelectorOnMainThread:@selector(setImage:)
                                                                         withObject:tmpImage
                                                                      waitUntilDone:YES];
                                }
                            }
                            else {
                                NSLog(@"Image snapshot url is null. Use default");
                            }
                        }
                        else {
                            NSLog(@"Event has no data");
                        }
                        
                        break;
                    }
                }
            }
            else {
                NSLog(@"Events empty!");
            }
        }
        else {
            NSLog(@"Response status != 200");
        }
    }
    else {
        NSLog(@"responseDict is nil");
    }
    
    [_activityIndicatorViewLoading stopAnimating];
    
    if ( !_imageViewSnapshot.image ) {
        // No snapshot image from server
        [_imageViewSnapshot performSelectorOnMainThread:@selector(setImage:)
                                                 withObject:[UIImage imageNamed:@"ImgNotAvailable"]
                                              waitUntilDone:NO];
    }
    
    NSString *urlFile = [_clipsInEvent[0] objectForKey:@"file"];
    
    if (([urlFile isEqual:[NSNull null]] || [urlFile isEqualToString:@""] || urlFile == nil) && _isBackgroundTaskRunning) {
        [self performSelectorInBackground:@selector(getEventSnapshot) withObject:nil];
    }
    else {
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getEventSnapshot) object:nil];
}


@end
