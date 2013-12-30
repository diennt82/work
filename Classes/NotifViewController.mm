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

@property (nonatomic) BOOL eventsListAlready;
@property (nonatomic, retain) NSMutableArray *events;
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
        if (_events != nil &&
            _events.count > 1)
        {
            NSDictionary *firsetEvent = [_events objectAtIndex:1];
            
            PlaylistInfo *clipInfo = [[PlaylistInfo alloc] init];
            clipInfo.urlFile = [firsetEvent objectForKey:@"clip_url"];
            
            if (clipInfo.urlFile != nil &&
                ![clipInfo.urlFile isEqualToString:@""])
            {
                PlaybackViewController *playbackVC = [[PlaybackViewController alloc] init];
                playbackVC.clip_info = clipInfo;
                playbackVC.clipsInEvent = _clipsInEvent;
                
                [self.navigationController pushViewController:playbackVC animated:YES];
                
                [playbackVC release];
            }
            
            [clipInfo release];
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

#pragma mark - Methods

- (void)getEventSnapshot_bg
{
    //2013-12-20 20:10:18 (yyyy-MM-dd HH:mm:ss).
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSString * event_code = [NSString stringWithFormat:@"0%@_%@", self.alertType, self.alertVal];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
#if 0
    NSDictionary *responseDict = [jsonComm getEventsFromURLString:@"http://nxcomm-office.no-ip.info/release/events/event_template4.txt"];
    NSLog(@"getLatestEventSnapshot_bg-responseDict: %@", responseDict);
    
    if (responseDict != nil)
    {
        self.events = [responseDict objectForKey:@"events"];
        
        if (_events != nil &&
            _events.count > 1)
        {
            NSString *urlString = [[_events objectAtIndex:0] objectForKey:@"snaps_url"];
            
            if (urlString != [NSNull class])
            {
                UIImage *tmpImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
                
                if (tmpImage != NULL)
                {
                    [self.imageViewSnapshot performSelectorOnMainThread:@selector(setImage:) withObject:tmpImage waitUntilDone:NO];
                }
            }
            
            else
            {
                NSLog(@"Image snapshot url is null. Use default");
            }
        }
        else
        {
            NSLog(@"Events empty!");
        }
    }
    
#else
    NSDictionary *responseDict = [jsonComm getListOfEventsBlockedWithRegisterId:_cameraMacNoColon
                                                                beforeStartTime:@""//@"2013-12-28 20:10:18"
                                                                      eventCode:@""//event_code // temp
                                                                         alerts:@"4"
                                                                           page:@""
                                                                         offset:@""
                                                                           size:@""
                                                                         apiKey:apiKey];
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            //4 44334C31A004 20130914055827490 2013-09-14T05:59:05+00:00 Camera-31a004
            
            // work
            
            self.events = [NSMutableArray array];
            self.events = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            if (_events != nil &&
                _events.count > 0)
            {
                for (NSDictionary *event in _events)
                {
                    if ([[[event objectForKey:@"value"] stringValue] isEqualToString:_alertVal])
                    {
                        // is this event
                        
                        self.clipsInEvent = [event objectForKey:@"data"];
                        
                        if (_clipsInEvent != nil &&
                            _clipsInEvent.count > 0)
                        {
                            NSString *urlImgString = [[_clipsInEvent objectAtIndex:0] objectForKey:@"image"];
                            
                            if (urlImgString != [NSNull class])
                            {
                                UIImage *tmpImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImgString]]];
                                
                                if (tmpImage != NULL)
                                {
                                    [self.imageViewSnapshot performSelectorOnMainThread:@selector(setImage:) withObject:tmpImage waitUntilDone:NO];
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
    
#endif
    
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
    [super dealloc];
}
@end
