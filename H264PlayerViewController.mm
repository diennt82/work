//
//  H264PlayerViewController.m
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#define D1 @"480p"
#define HD1 @"720p-10"
#define HD15 @"720p-15"

#define DIRECTION_V_NON  0x01
#define DIRECTION_V_UP   0x02
#define DIRECTION_V_DN   0x04
#define DIRECTION_V_MASK 0xF0

#define DIRECTION_H_NON 0x10
#define DIRECTION_H_LF  0x20
#define DIRECTION_H_RT  0x40
#define DIRECTION_H_MASK 0x0F

#define VIEW_DIRECTIONPAD_TAG 999

#import "H264PlayerViewController.h"

#import "HttpCommunication.h"
#import "PlaylistInfo.h"
#import "PlaybackViewController.h"
#import "PlaylistCell.h"
#import "MTStackViewController.h"
#import "HttpCommunication.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import <H264MediaPlayer/H264MediaPlayer.h>


@interface H264PlayerViewController ()
<UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    MediaPlayer* mp;
}

@property (retain, nonatomic) IBOutlet UITableView *tableViewPlaylist;
@property (retain, nonatomic) IBOutlet UIView *viewCtrlButtons;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerHQOptions;
@property (retain, nonatomic) IBOutlet UIButton *hqViewButton;
@property (retain, nonatomic) IBOutlet UIButton *triggerRecordingButton;
@property (retain, nonatomic) IBOutlet UIImageView *imgViewDrectionPad;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *barBntItemReveal;

@property (nonatomic, retain) HttpCommunication* httpComm;
@property (nonatomic, retain) NSMutableArray *playlistArray;
@property (nonatomic) BOOL mpFlag;
@property (nonatomic, retain) NSArray *eventArr;
@property (nonatomic, retain) HttpCommunication *htppComm;
@property (nonatomic, retain) BMS_JSON_Communication *jsonComm;
@property (nonatomic) BOOL recordingFlag;

/* Direction */
@property (nonatomic, retain) NSTimer * send_UD_dir_req_timer;
@property (nonatomic, retain) NSTimer * send_LR_dir_req_timer;
/* Added to support direction update */
@property (nonatomic) int currentDirUD, lastDirUD;
@property (nonatomic) int delay_update_lastDir_count;
@property (nonatomic) int currentDirLR,lastDirLR;
@property (nonatomic) int delay_update_lastDirLR_count;

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
    
//    NSString * msg = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
//                                                       @"Back", nil);
//    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
//                                                                   style:UIBarButtonItemStylePlain
//                                                                  target:[self stackViewController]
//                                                                  action:@selector(toggleLeftViewController)];
    
    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(preToggleLeftViewController)];

    self.navigationItem.leftBarButtonItem = revealIcon;
//	self.navigationItem.backBarButtonItem =
//    [[[UIBarButtonItem alloc] initWithTitle:msg
//                                      style:UIBarButtonItemStyleBordered
//                                     target:nil
//                                     action:nil] autorelease];
    self.tableViewPlaylist.delegate = self;
    self.tableViewPlaylist.dataSource = self;
    self.tableViewPlaylist.rowHeight = 68;
    
    self.pickerHQOptions.delegate = self;
    self.pickerHQOptions.dataSource = self;
    
    //self.barBntItemReveal.target = [self stackViewController];
    
    [self becomeActive];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self checkOrientation];
    
//    if (self.mpFlag) {
//        self.progressView.hidden = NO;
//        //[self.view bringSubviewToFront:self.progressView];
//        [self setupCamera];
//        //[self performSelectorInBackground:@selector(loadEarlierList) withObject:nil];
//        [self loadEarlierList];
//        self.mpFlag = FALSE;
//    }
}

#pragma mark - Action

- (IBAction)segCtrlAction:(id)sender {
    
    if (self.segCtrl.selectedSegmentIndex == 0) {
        
        self.tableViewPlaylist.hidden = YES;
        
        if (self.mpFlag) {
            self.progressView.hidden = NO;
            //[self.view bringSubviewToFront:self.progressView];
            [self setupCamera];
            self.mpFlag = FALSE;
        }
        else
        {
            //[self.view bringSubviewToFront:self.imageViewVideo];
        }
    }
    else if (self.segCtrl.selectedSegmentIndex == 1)
    {
        if (self.playlistArray.count == 0) {
            self.progressView.hidden = NO;
        }
        
        self.tableViewPlaylist.hidden = NO;
        [self.view bringSubviewToFront:self.tableViewPlaylist];
    }
    
    NSLog(@"self.segCtrl.selectedSegmentIndex = %d", self.segCtrl.selectedSegmentIndex);
}
- (IBAction)hqPressAction:(id)sender {
    self.pickerHQOptions.hidden = NO;
    [self.view bringSubviewToFront:self.pickerHQOptions];
}
- (IBAction)iFrameOnlyPressAction:(id)sender {
}
- (IBAction)recordingPressAction:(id)sender {
    self.recordingFlag = !self.recordingFlag;
    
    NSString *modeRecording = @"";
    
    if (self.recordingFlag) {
        modeRecording = @"on";
    }
    else
    {
        modeRecording = @"off";
    }
    
    [self performSelectorInBackground:@selector(setTriggerRecording_bg:)
                           withObject:modeRecording];
}

- (IBAction)barBntItemRevealAction:(id)sender {
//    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
//                                                                  style:UIBarButtonItemStylePlain
//                                                                 target:[self stackViewController]
//                                                                 action:@selector(toggleLeftViewController)];
    //[self.stackViewController toggleLeftViewController];
}

- (void)preToggleLeftViewController
{
    [self.stackViewController toggleLeftViewController];
}
#pragma mark - Method

- (void)becomeActive
{
    //CamProfile *cp = self.selectedChannel.profile;
    
    //Set camera name
    //self.cameraNameBarBtnItem.title = cp.name;
    
    //set Button handler
    self.backBarBtnItem.target = self;
    self.backBarBtnItem.action = @selector(goBackToCameraList);
//SLIDE MENU
//    self.backBarBtnItem.target = self.stackViewController;
//    self.backBarBtnItem.action = @selector(toggleLeftViewController);
    
    self.progressView.hidden = NO;
    //[self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
//    [self performSelector:@selector(startStream)
//               withObject:nil
//               afterDelay:0.1];
    NSLog(@"self.segCtrl.selectedSegmentIndex = %d", self.segCtrl.selectedSegmentIndex);
    
    [self setupCamera];
    
    [self performSelectorInBackground:@selector(loadEarlierList) withObject:nil];

    if (self.segCtrl.selectedSegmentIndex == 0) {
        self.tableViewPlaylist.hidden= YES;
    }
    
    //Direction stuf
    /* Kick off the two timer for direction sensing */
    _currentDirUD = DIRECTION_V_NON;
    _lastDirUD    = DIRECTION_V_NON;
    _delay_update_lastDir_count = 1;
    
    _send_UD_dir_req_timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                             target:self
                                                           selector:@selector(v_directional_change_callback:)
                                                           userInfo:nil
                                                            repeats:YES];
    
    _currentDirLR = DIRECTION_H_NON;
    _lastDirLR    = DIRECTION_H_NON;
    _delay_update_lastDirLR_count = 1;
    
    _send_LR_dir_req_timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                             target:self
                                                           selector:@selector(h_directional_change_callback:)
                                                           userInfo:nil
                                                            repeats:YES];
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
        
        //self.progressView.hidden = YES;
        [self performSelector:@selector(startStream)
                   withObject:nil
                   afterDelay:0.1];
        [self performSelectorInBackground:@selector(getVQ_bg) withObject:nil];
        //[self performSelectorInBackground:@selector(getTriggerRecording_bg) withObject:nil];
    }
    else if (self.selectedChannel.profile.minuteSinceLastComm <= 5)
    {
        NSLog(@"created a remote streamer");
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
        NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
        
//        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
//                                                                                 Selector:@selector(createSesseionSuccessWithResponse:)
//                                                                             FailSelector:@selector(createSessionFailedWithResponse:)
//                                                                                ServerErr:@selector(createSessionFailedUnreachableSerever)];
//        [jsonComm createSessionWithRegistrationId:mac
//                                    andClientType:@"IOS"
//                                        andApiKey:apiKey];
        BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                                 Selector:nil
                                                                             FailSelector:nil
                                                                                ServerErr:nil] autorelease];
        NSDictionary *responseDict = [jsonComm createSessionBlockedWithRegistrationId:mac
                                                                     andClientType:@"IOS"
                                                                         andApiKey:apiKey];
        if (responseDict) {
            if ([[responseDict objectForKey:@"status"] intValue] == 200) {
                self.stream_url = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
                
                NSString *tempString = [[self.stream_url componentsSeparatedByString:@"/"] lastObject];
                
                if ([tempString isEqualToString:@"blinkhd"] ) {
                    return;
                }
                [self performSelector:@selector(startStream)
                           withObject:nil
                           afterDelay:0.1];
                [self performSelectorInBackground:@selector(getVQ_bg) withObject:nil];
                //[self performSelectorInBackground:@selector(getTriggerRecording_bg) withObject:nil];
            }
        }
        else
        {
            NSLog(@"create session isn't success");
        }

    }
    else
    {
        self.progressView.hidden = YES;
        NSLog(@"Camera maybe not available.");
    }
}

-(void) startStream
{
    status_t status;

    mp = new MediaPlayer(false);
    
    //`NSLog(@"Play with TCP Option >>>>> ") ;
    //mp->setPlayOption(MEDIA_STREAM_RTSP_WITH_TCP);
    
    NSString * url ;//=@"http://192.168.3.116:6667/blinkhd";
    
    url = _stream_url;
    
    
    status = mp->setDataSource([url UTF8String]);
    
    
    
    if (status != NO_ERROR) // NOT OK
    {
        
        
        return;
    }
    
    mp->setVideoSurface(self.imageViewVideo);
    
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
}

- (void)goBackToCameraList
{
    
    [self stopStream];
    
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)stopStream
{
    @synchronized(self)
    {
        if (mp != NULL)
        {
            if (mp->isPlaying())
            {
                mp->suspend();
                mp->stop();
            }
            free(mp);
        }
        mp = NULL;
    }
}

- (void)loadEarlierList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
//    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
//                                                                             Selector:@selector(getPlaylistSuccessWithResponse:)
//                                                                         FailSelector:@selector(getPlaylistFailedWithResponse:)
//                                                                            ServerErr:@selector(getPlaylistUnreachableSetver)];
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
//    [jsonComm getAllRecordedFilesWithRegistrationId:mac
//                                           andEvent:@"04"
//                                          andApiKey:apiKey];
    NSDictionary *responseDict = [jsonComm getAllRecordedFilesBlockedWithRegistrationId:mac
                                                  andEvent:@"04"
                                                 andApiKey:apiKey];
    if (responseDict) {
        if ([[responseDict objectForKey:@"status"] intValue] == 200) {
            self.eventArr = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            //[self.tableViewPlaylist reloadData];
            
            self.playlistArray = [NSMutableArray array];
            
            for (NSDictionary *playlist in self.eventArr) {
                NSDictionary *clipInfo = [[playlist objectForKey:@"playlist"] objectAtIndex:0];
                
                PlaylistInfo *playlistInfo = [[[PlaylistInfo alloc] init] autorelease];
                playlistInfo.urlImage = [clipInfo objectForKey:@"image"];
                playlistInfo.titleString = [clipInfo objectForKey:@"title"];
                playlistInfo.urlFile = [clipInfo objectForKey:@"file"];
                
                [self.playlistArray addObject:playlistInfo];
                //[self.tableViewPlaylist reloadData];
            }
            
            //[self.tableViewPlaylist performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [self.tableViewPlaylist reloadData];
            NSLog(@"reloadData %d", self.playlistArray.count);
            
            //[self performSelectorInBackground:@selector(downloadImage) withObject:nil];
        }
    }
    
    self.progressView.hidden = YES;
}

//- (void)downloadImage
//{
//    
//}

-(void) getVQ_bg
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *responseDict  = nil;
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSLog(@"mac %@, apikey %@", mac, apiKey);
   
    
    if (self.selectedChannel.profile.isInLocal ) // Replace with httpCommunication after
	{
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
		if (self.jsonComm != nil)
		{
            responseDict= [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                   andCommand:@"action=command&command=get_resolution"
                                                                    andApiKey:apiKey];
		}
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
	{
		self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
		if (self.jsonComm != nil)
		{
            responseDict= [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                   andCommand:[NSString stringWithFormat:@"action=command&command=get_resolution"] andApiKey:apiKey];
		}
	}

	if (responseDict != nil)
	{
        
//        NSInteger status = [[responseDict objectForKey:@"status"] intValue];
//		if (status == 200)
//		{
//			NSString *bodyKey = [[[responseDict objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
//            NSString *modeVideo = [[bodyKey componentsSeparatedByString:@": "] objectAtIndex:1];
//			
//            [self performSelectorOnMainThread:@selector(setVQForground:)
//                                   withObject:modeVideo waitUntilDone:NO];
//		}
        [self performSelectorOnMainThread:@selector(setVQ_fg:) withObject:responseDict waitUntilDone:NO];
	}
    
    NSLog(@"getVQ_bg responseDict = %@", responseDict);
}

- (void)setVQForground: (NSString *)modeVideo
{
    if ([modeVideo isEqualToString:@"480p"]) // ok
    {
        [self.hqViewButton setImage:[UIImage imageNamed:@"hq_d.png" ]
                           forState:UIControlStateNormal];
    }
    else if([modeVideo isEqualToString:@"720p_10"] || [modeVideo isEqualToString:@"720p_15"])
    {
        [self.hqViewButton setImage:[UIImage imageNamed:@"hq.png" ]
                           forState:UIControlStateNormal];
    }
}

- (void)getTriggerRecording_bg
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *responseDict  = nil;
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSLog(@"mac %@, apikey %@", mac, apiKey);
    
    
    if (self.selectedChannel.profile.isInLocal ) // Replace with httpCommunication after
	{
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
		if (self.jsonComm != nil)
		{
            responseDict= [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                   andCommand:@"action=command&command=get_recording_stat"
                                                                    andApiKey:apiKey];
		}
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5) // Remote
	{
		self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
		if (self.jsonComm != nil)
		{
            responseDict= [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                   andCommand:[NSString stringWithFormat:@"action=command&command=get_recording_stat"] andApiKey:apiKey];
		}
	}
    
	if (responseDict != nil)
	{
        [self performSelectorOnMainThread:@selector(setTriggerRecording_fg::) withObject:responseDict waitUntilDone:NO];
	}
    
    NSLog(@"getVQ_bg responseDict = %@", responseDict);
}

- (void)setTriggerRecording_bg:(NSString *) modeRecording
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSDictionary *responseData  = nil;
    if (  self.selectedChannel.profile.isInLocal)
	{
        
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
        
		if (self.jsonComm != nil) // This is httpComm. Replace after
		{
            
            
            //            [self.jsonComm sendCommandWithRegistrationId:mac
            //                                             andCommand:[NSString stringWithFormat:@"action=command&command=%@", modeVideo]
            //                                              andApiKey:apiKey];
            responseData = [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                    andCommand:[NSString stringWithFormat:@"action=command&command=set_recording_stat&mode=%@", modeRecording]
                                                                     andApiKey:apiKey];
		}
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5)
	{
        
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
        
        if (self.jsonComm != nil)
		{
            responseData = [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                    andCommand:[NSString stringWithFormat:@"action=command&command=set_recording_stat&mode=%@", modeRecording]
                                                                     andApiKey:apiKey];
		}
	}
    
	if (responseData != nil)
	{
		[self performSelectorOnMainThread:@selector(setTriggerRecording_fg:)
                               withObject:responseData waitUntilDone:NO];
	}
}

-(void) setTriggerRecording_fg: (NSDictionary *)responseData
{
    
    NSLog(@"setTriggerRecording_fg responseData = %@", responseData);
    
    NSInteger status = [[responseData objectForKey:@"status"] intValue];
    
    
    if (status == 200) // ok
    {
        if (self.recordingFlag) {
            [self.triggerRecordingButton setImage:[UIImage imageNamed:@"bb_rec_icon.png" ]
                                         forState:UIControlStateNormal];
        }
        else
        {
            [self.triggerRecordingButton setImage:[UIImage imageNamed:@"bb_rec_icon_d.png" ]
                                         forState:UIControlStateNormal];
        }
    }
    else
    {
        self.recordingFlag = !self.recordingFlag;
    }
}

#pragma mark -
#pragma mark - DirectionPad

/* Periodically called every 200ms */
- (void) v_directional_change_callback:(NSTimer *) timer_exp
{
	/* currentDirUD holds the LATEST direction,
     lastDirUD holds the LAST direction that we have seen
     - this is called every 100ms
	 */
	@synchronized(_imgViewDrectionPad)
	{
        
		if (_lastDirUD != DIRECTION_V_NON)
        {
			[self send_UD_dir_to_rabot:_currentDirUD];
		}
        
		//Update directions
		_lastDirUD = _currentDirUD;
	}
}

- (void) send_UD_dir_to_rabot:(int ) direction
{
	NSString * dir_str = nil;
	float duty_cycle = 0;
    
	switch (direction) {
		case DIRECTION_V_NON:
            
			dir_str= FB_STOP;
			break;
            
		case DIRECTION_V_DN	:
            
			duty_cycle = IRABOT_DUTYCYCLE_MAX +0.1;
			dir_str= MOVE_DOWN;
			dir_str = [NSString stringWithFormat:@"%@%.1f", dir_str, duty_cycle];
            
			break;
		case DIRECTION_V_UP	:
            
			duty_cycle = IRABOT_DUTYCYCLE_MAX ;
			dir_str= MOVE_UP;
			dir_str = [NSString stringWithFormat:@"%@%.1f", dir_str, duty_cycle];
			break;
		default:
			break;
	}
    
	if (dir_str != nil)
	{
        if (_selectedChannel.profile.isInLocal)
		{
            _httpComm = [[[HttpCommunication alloc] init] autorelease];
				//Non block send-
				[_httpComm sendCommand:dir_str];
                //[_httpComm sendCommandAndBlock:dir_str];
		}
		else if(_selectedChannel.profile.minuteSinceLastComm <= 5)
		{
            NSString *mac = [Util strip_colon_fr_mac:_selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            _jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                               Selector:nil
                                                           FailSelector:nil
                                                              ServerErr:nil] autorelease];
            NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                              andCommand:[NSString stringWithFormat:@"action=command&command=%@", dir_str]
                                                                               andApiKey:apiKey];
            NSLog(@"send_UD_dir_to_rabot status: %d", [[responseDict objectForKey:@"status"] intValue]);
		}
	}
}

- (void) h_directional_change_callback:(NSTimer *) timer_exp
{
    BOOL need_to_send = FALSE;
    
    @synchronized(_imgViewDrectionPad)
	{
		if ( _lastDirLR != DIRECTION_H_NON)
        {
			need_to_send = TRUE;
		}
        
        if (need_to_send)
        {
            [self send_LR_dir_to_rabot: _currentDirLR];
        }
        
		//Update directions
		_lastDirLR = _currentDirLR;
	}
}

- (void) send_LR_dir_to_rabot:(int ) direction
{
	NSString * dir_str = nil;
    
	switch (direction)
    {
		case DIRECTION_H_NON:
            
			dir_str= LR_STOP;
			break;
		case DIRECTION_H_LF	:
            
			dir_str= MOVE_LEFT;
			dir_str= [NSString stringWithFormat:@"%@%.1f", dir_str,(float) IRABOT_DUTYCYCLE_LR_MAX];
            
			break;
		case DIRECTION_H_RT	:
            
			dir_str= MOVE_RIGHT;
			dir_str= [NSString stringWithFormat:@"%@%.1f", dir_str,(float) IRABOT_DUTYCYCLE_LR_MAX];
            
			break;
		default:
			break;
	}
    
    NSLog(@"dir_str: %@", dir_str);
    
	if (dir_str != nil)
	{
        if (_selectedChannel.profile.isInLocal)
        {
            _httpComm = [[[HttpCommunication alloc] init] autorelease];
				//Non block send-
				[_httpComm sendCommand:dir_str];
                
                //[_httpComm sendCommandAndBlock:dir_str];
		}
		else if ( _selectedChannel.profile.minuteSinceLastComm <= 5)
		{
            NSString *mac = [Util strip_colon_fr_mac:_selectedChannel.profile.mac_address];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
            
            _jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
            NSDictionary *responseDict = [_jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                              andCommand:[NSString stringWithFormat:@"action=command&command=%@", dir_str]
                                                                               andApiKey:apiKey];
            NSLog(@"send_LR_dir_to_rabot status: %d", [[responseDict objectForKey:@"status"] intValue]);
		}
	}
}

- (void) updateVerticalDirection_begin:(int)dir inStep: (uint) step
{
	unsigned int newDirection = 0;
    
	if (dir == 0)
	{
		newDirection = DIRECTION_V_NON;
	}
	else //Dir is either V_UP or V_DN
	{
		if (dir >0)
		{
			newDirection = DIRECTION_V_DN;
		}
		else
		{
			newDirection = DIRECTION_V_UP;
		}
	}
    
	@synchronized(_imgViewDrectionPad)
	{
		_currentDirUD = newDirection;
	}
    
	//Adjust the fire date to now
	NSDate * now = [NSDate date];
	[_send_UD_dir_req_timer setFireDate:now ];    
}

- (void) updateVerticalDirection:(int)dir inStep: (uint) step withAnimation:(BOOL)animate
{
	unsigned int newDirection = 0;
    
	if (dir == 0)
	{
		newDirection = DIRECTION_V_NON;
	}
	else //Dir is either V_UP or V_DN
	{
		if (dir >0)
		{
			newDirection = DIRECTION_V_DN;
		}
		else
		{
			newDirection = DIRECTION_V_UP;
		}
	}
    
	@synchronized(_imgViewDrectionPad)
	{
		_currentDirUD = newDirection;
	}
}

- (void) updateVerticalDirection_end:(int)dir inStep: (uint) step
{
	@synchronized(_imgViewDrectionPad)
	{
		_currentDirUD = DIRECTION_V_NON;
	}
}

- (void) updateHorizontalDirection_end:(int)dir inStep: (uint) step
{
	@synchronized(_imgViewDrectionPad)
	{
		_currentDirLR = DIRECTION_H_NON;
	}
}

- (void)updateHorizontalDirection_begin:(int)dir inStep: (uint) step
{
	unsigned int newDirection = 0;
    
	if (dir == 0)
	{
		newDirection = DIRECTION_H_NON;
	}
	else
	{
		if (dir >0)
		{
			newDirection = DIRECTION_H_RT;
		}
		else
		{
			newDirection = DIRECTION_H_LF;
		}
	}
    
	@synchronized(_imgViewDrectionPad)
	{
		_currentDirLR = newDirection;
	}
    
	//Adjust the fire date to now
	NSDate * now = [NSDate date];
	[_send_LR_dir_req_timer setFireDate:now ];
}

- (void) updateHorizontalDirection:(int)dir inStep: (uint) step withAnimation:(BOOL) animate
{
	unsigned int newDirection = 0;
    
	if (dir == 0)
	{
		newDirection = DIRECTION_H_NON;
	}
	else
	{
		if (dir >0)
		{
			newDirection = DIRECTION_H_RT;
		}
		else
		{
			newDirection = DIRECTION_H_LF;
		}
	}
    
	@synchronized(_imgViewDrectionPad)
	{
		_currentDirLR = newDirection;
	}
}

#pragma  mark -
#pragma mark Touches

//----- handle all touches here then propagate into directionview

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *allTouches = [touches allObjects];
    
    for (UITouch *touch in allTouches)
    {
        if(touch.view.tag == 999)
        {
            NSLog(@"ok");
            CGPoint location = [touch locationInView:touch.view];
            [self touchEventAt:location phase:touch.phase];
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *allTouches = [touches allObjects];
    
    for (UITouch *touch in allTouches)
    {
        if(touch.view.tag == 999)
        {
            NSLog(@"ok");
            CGPoint location = [touch locationInView:touch.view];
            [self touchEventAt:location phase:touch.phase];
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{        
	NSArray *allTouches = [touches allObjects];
    
    for (UITouch *touch in allTouches)
    {
        if(touch.view.tag == 999)
        {
            NSLog(@"ok");
            CGPoint location = [touch locationInView:touch.view];
            [self touchEventAt:location phase:touch.phase];
        }
    }
}

- (void) touchEventAt:(CGPoint) location phase:(UITouchPhase) phase
{
	switch (phase)
    {
		case UITouchPhaseBegan:
			[self _touchesbegan:location];
			break;
		case UITouchPhaseMoved:
		case UITouchPhaseStationary:
			[self _touchesmoved:location];
			break;
		case UITouchPhaseEnded:
			[self _touchesended:location];
            
		default:
			break;
	}
}

- (void) _touchesbegan: (CGPoint) location
{
	[self validatePoint:location newMovement:YES ];
}

- (void) _touchesmoved: (CGPoint) location
{
	/*when moved, the new point may change from vertical to Horizontal plane ,
     thus reset it here,
     later the point will be re-evaluated  and set to the corrent command*/
    
    [self updateVerticalDirection_end:0 inStep:0];
    
	[self updateHorizontalDirection_end:0 inStep:0];
    
    [self validatePoint:location newMovement:NO ];
}

- (void) _touchesended: (CGPoint) location
{
	CGPoint beginLocation = CGPointMake(_imgViewDrectionPad.center.x - _imgViewDrectionPad.frame.origin.x,
                                        _imgViewDrectionPad.center.y - _imgViewDrectionPad.frame.origin.y);
    
	[self validatePoint:beginLocation newMovement:NO ];
    
    
	[self updateVerticalDirection_end:0 inStep:0];
    
	[self updateHorizontalDirection_end:0 inStep:0];
}

- (void) validatePoint: (CGPoint)location newMovement:(BOOL) isBegan
{
	CGPoint translation ;
    
	BOOL is_vertical;
    
	CGPoint beginLocation = CGPointMake(_imgViewDrectionPad.center.x - _imgViewDrectionPad.frame.origin.x,
                                        _imgViewDrectionPad.center.y - _imgViewDrectionPad.frame.origin.y);
    
	translation.x =  location.x - beginLocation.x;
	translation.y =  location.y - beginLocation.y;
	//NSLog(@"val: tran: %f %f", translation.x, translation.y);
	is_vertical = YES;
	if ( abs(translation.x) >  abs(translation.y))
	{
		is_vertical = NO;
	}
    
	if (is_vertical == YES)
	{
		///TODOO: update image
		if (translation.y > 0)
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_dn.png"]];
		}
		else if (translation.y <0)
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_up.png"]];
		}
		else
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_2.png"]];
		}
        
		if (isBegan)
		{
            
			[self updateVerticalDirection_begin:translation.y inStep:0];
		}
		else
		{
			[self updateVerticalDirection:translation.y inStep:0 withAnimation:FALSE];
		}
        
	}
	else
	{
		///TODOO: update image
		if (translation.x > 0)
		{
            
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_rt.png"]];
		}
		else if (translation.x < 0){
            
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_lf.png"]];
		}
		else
		{
			[_imgViewDrectionPad setImage:[UIImage imageNamed:@"circle_buttons1_2.png"]];
		}
        
		if (isBegan)
		{
			[self updateHorizontalDirection_begin:translation.x inStep:0];
		}
		else {
            
			[self updateHorizontalDirection:translation.x inStep:0 withAnimation:FALSE];
		}
	}
}

#pragma mark - JSON Callback

- (void)createSesseionSuccessWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"createSesseionSuccessWithResponse %@", responseDict);
    if (responseDict) {
        if ([[responseDict objectForKey:@"status"] intValue] == 200) {
            self.stream_url = [[responseDict objectForKey:@"data"] objectForKey:@"url"];
            
            NSString *tempString = [[self.stream_url componentsSeparatedByString:@"/"] lastObject];
            
            if ([tempString isEqualToString:@"blinkhd"] ) {
                return;
            }
            [self performSelector:@selector(startStream)
                       withObject:nil
                       afterDelay:0.1];
            [self performSelectorInBackground:@selector(getVQ_bg) withObject:nil];
        }
    }
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
	return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self adjustViewsForOrientation:toInterfaceOrientation];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame]; // Get status bar frame dimensions
    NSLog(@"1 Statusbar frame: %1.0f, %1.0f, %1.0f, %1.0f", rect.origin.x,
          rect.origin.y, rect.size.width, rect.size.height);
    //HACK : incase hotspot is turned on
    if (rect.size.height>21 &&  rect.size.height<50)
    {

    }

    else
    {
        
    }
}

-(void) checkOrientation
{
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land_ipad"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 1024, 576);
            self.imageViewVideo.frame = newRect;
        }
        else
        {
            
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 480, 256);
            self.imageViewVideo.frame = newRect;
            self.viewCtrlButtons.frame = CGRectMake(0, 106, _viewCtrlButtons.frame.size.width, _viewCtrlButtons.frame.size.height);
            self.imgViewDrectionPad.frame = CGRectMake(180, 180, _imgViewDrectionPad.frame.size.width, _imgViewDrectionPad.frame.size.height);
            //self.progressView.frame = CGRectMake(0, 44, 480, 320);
            
//            imageView.frame = CGRectMake(
//                                         imageView.frame.origin.x,
//                                         imageView.frame.origin.y, newWidth, newHeight);
//            
//            imageView.contentMode = UIViewContentModeBottomLeft; // This determines position of image
//            imageView.clipsToBounds = YES;
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
        }
        else
        {
        }
        
		//Rotate the slider
		//zoombarView.transform = CGAffineTransformRotate(zoombarView.transform, -M_PI*0.5);
		//Initializng the slider value to zero.
		//self.zoombar.value=currentZoomLvl*ZOOM_STEP;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
        }
        else
        {
        }
        
        //if (fwUpgradeInProgess == TRUE)
        {
        }
        
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_ipad"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 768, 432);
            self.imageViewVideo.frame = newRect;
        }
        else
        {
//            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController"
//                                          owner:self
//                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 320, 180);
            self.imageViewVideo.frame = newRect;
            self.viewCtrlButtons.frame = CGRectMake(0, 44, _viewCtrlButtons.frame.size.width, _viewCtrlButtons.frame.size.height);
            self.imgViewDrectionPad.frame = CGRectMake(100, 180, _imgViewDrectionPad.frame.size.width, _imgViewDrectionPad.frame.size.height);
            //self.progressView.frame = CGRectMake(0, 44, 320, 480);
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
        }
        else
        {
        }

        //if (fwUpgradeInProgess == TRUE)
        {
        }
	}
    
    [self checkIphone5Size:orientation];

    self.backBarBtnItem.target = self;
    self.backBarBtnItem.action = @selector(goBackToCameraList);
// SLIDE MENU
//    self.backBarBtnItem.target = self.stackViewController;
//    self.backBarBtnItem.action = @selector(toggleLeftViewController);
}

- (void) checkIphone5Size: (UIInterfaceOrientation)orientation
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568)
    {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            NSLog(@"iphone5 SHift right...");
//            CGAffineTransform translate = CGAffineTransformMakeTranslation(44, 0);
//            self.imageViewVideo.transform = translate;
            CGRect newRect = CGRectMake(0, 0, 568, 320);
            self.imageViewVideo.frame = newRect;
            
//            self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, self.progressView.frame.size.width + 88, self.progressView.frame.size.height);
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"self.playlistArray.count = %d", self.playlistArray.count);
    //return self.eventArr.count;
    return self.playlistArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:.8 green:.8 blue:1 alpha:1]];
    }
    else
        [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
    
    static NSString *CellIdentifier = @"PlaylistCell";
    PlaylistCell *cell = [self.tableViewPlaylist dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PlaylistCell" owner:nil options:nil];
    for (id curObj in objects) {
        if([curObj isKindOfClass:[UITableViewCell class]]){
            cell = (PlaylistCell *)curObj;
            break;
        }
    }
    
    // Configure the cell...
    
    PlaylistInfo *playlistInfo = [self.playlistArray objectAtIndex:indexPath.row];
    if (playlistInfo) {
        cell.imgViewSnapshot.image = [UIImage imageNamed:@"no_img_available.jpeg"];
        
        if (!playlistInfo.imgSnapshot) {
            [cell.activityIndicator startAnimating];
            
            CGSize newSize = CGSizeMake(64, 64);
            
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                playlistInfo.imgSnapshot = [self imageWithUrlString:playlistInfo.urlImage scaledToSize:newSize];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"img = %@", img);
                    cell.imgViewSnapshot.image = playlistInfo.imgSnapshot;
                    [cell.activityIndicator stopAnimating];
                    cell.activityIndicator.hidden = YES;
                });
            });
        }
        else
        {
            NSLog(@"playlistInfo.imgSnapshot already");
            cell.imgViewSnapshot.image = playlistInfo.imgSnapshot;
        }
        
        if (playlistInfo.titleString && ![playlistInfo.titleString isEqualToString:@""]) {
            cell.labelTitle.text = playlistInfo.titleString;
        }
        else
        {
            cell.labelTitle.text = @"Motion Detected";
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (UIImage *)imageWithUrlString:(NSString *)urlString scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
    
	[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    PlaylistInfo *playlistInfo = (PlaylistInfo *)[self.playlistArray objectAtIndex:indexPath.row];
    
    NSLog(@"urlFile = %@", playlistInfo.urlFile);
    
    if(playlistInfo.urlFile &&
       ![playlistInfo.urlFile isEqualToString:@""] &&
       playlistInfo.imgSnapshot)
    {
        PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
        playbackViewController.urlVideo = playlistInfo.urlFile;
        if (mp != nil)
        {
            [self stopStream];
            self.mpFlag = TRUE;
        }
        
        [self.navigationController pushViewController:playbackViewController animated:NO];
        [playbackViewController release];
    }
    else
    {
        NSLog(@"urlFile nil");
        [[[[UIAlertView alloc] initWithTitle:@"Sorry"
                                     message:@"Url file maybe empty. Or wait for load image"
                                    delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil]
          autorelease]
         show];
    }
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    NSString *textRow;
    switch (row) {
        case 0:
            textRow = @"D1";
            break;
        case 1:
            textRow = @"HD 1 Mbps";
            break;
        case 2:
            textRow = @"HD 1.5 Mbps";
            break;
            
        default:
            break;
    }
    return textRow;
} 


#pragma mark -
#pragma mark PickerView Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    // send command here
    pickerView.hidden = YES;
    
    [self performSelectorInBackground:@selector(setVQ_bg:)
                           withObject:[NSNumber numberWithInt:row]];
}

- (void)setVQ_bg:(NSNumber *) row
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	//int videoQ =[userDefaults integerForKey:@"int_VideoQuality"];
    
    NSString *modeVideo = @"";
    switch ([row intValue]) {
        case 0:
            modeVideo = @"480p";
            break;
        case 1:
            modeVideo = @"720p_10";
            break;
        case 2:
            modeVideo = @"720p_15";
            break;
        default:
            break;
    }
    
    NSString *mac = [Util strip_colon_fr_mac:self.selectedChannel.profile.mac_address];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSDictionary *responseData  = nil;
    if (  self.selectedChannel.profile.isInLocal)
	{
        
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
        
		if (self.jsonComm != nil) // This is httpComm. Replace after
		{
            
            
//            [self.jsonComm sendCommandWithRegistrationId:mac
//                                             andCommand:[NSString stringWithFormat:@"action=command&command=%@", modeVideo]
//                                              andApiKey:apiKey];
            responseData = [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                     andCommand:[NSString stringWithFormat:@"action=command&command=set_resolution&mode=%@", modeVideo]
                                                      andApiKey:apiKey];
		}
	}
	else if(self.selectedChannel.profile.minuteSinceLastComm <= 5)
	{
        
        self.jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                              Selector:nil
                                                          FailSelector:nil
                                                             ServerErr:nil] autorelease];
        
        if (self.jsonComm != nil)
		{
            responseData = [self.jsonComm sendCommandBlockedWithRegistrationId:mac
                                                                    andCommand:[NSString stringWithFormat:@"action=command&command=set_resolution&mode=%@", modeVideo]
                                                                     andApiKey:apiKey];
		}
	}
    
	if (responseData != nil)
	{
		[self performSelectorOnMainThread:@selector(setVQ_fg:)
                               withObject:responseData waitUntilDone:NO];
	}
}

-(void) setVQ_fg: (NSDictionary *)responseData
{
    
    NSLog(@"setVQ_fg responseData = %@", responseData);
    
    NSInteger status = [[responseData objectForKey:@"status"] intValue];
    
    
    if (status == 200) // ok
    {
        NSString *bodyKey = [[[responseData objectForKey:@"data"] objectForKey:@"device_response"] objectForKey:@"body"];
        
        NSRange range = [bodyKey rangeOfString:@": "];
        if (range.location != NSNotFound) {
            NSString *modeVideo = [[bodyKey componentsSeparatedByString:@": "] objectAtIndex:1];
            
            if ([modeVideo isEqualToString:@"480p"])
            {
                [self.hqViewButton setImage:[UIImage imageNamed:@"hq_d.png" ]
                                   forState:UIControlStateNormal];
            }
            else if([modeVideo isEqualToString:@"720p_10"] || [modeVideo isEqualToString:@"720p_15"])
            {
                [self.hqViewButton setImage:[UIImage imageNamed:@"hq.png" ]
                                   forState:UIControlStateNormal];
            }
        }
    }
    else
    {
        NSLog(@"status = %d", [[responseData objectForKey:@"stats"] intValue]);
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_imageViewVideo release];
    [_topToolbar release];
    [_backBarBtnItem release];
    [_progressView release];
    [_cameraNameBarBtnItem release];
    [_segCtrl release];
    [_tableViewPlaylist release];
    
    [_stream_url release];
    [_selectedChannel release];
    [_playlistArray release];
    [_httpComm release];
    
    [_barBntItemReveal release];
    [_viewCtrlButtons release];
    [_pickerHQOptions release];
    [_hqViewButton release];
    [_triggerRecordingButton release];
    [_imgViewDrectionPad release];
    [_send_UD_dir_req_timer invalidate];
    [_send_LR_dir_req_timer invalidate];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setImageViewVideo:nil];
    [self setTopToolbar:nil];
    [self setBackBarBtnItem:nil];
    [self setProgressView:nil];
    [self setCameraNameBarBtnItem:nil];
    [self setSegCtrl:nil];
    [self setTableViewPlaylist:nil];
    
    [self setStream_url:nil];
    [self setSelectedChannel:nil];
    [self setPlaylistArray:nil];
    [self setHttpComm:nil];
    [self setSend_UD_dir_req_timer:nil];
    [self setSend_LR_dir_req_timer:nil];
    
    [super viewDidUnload];
}
@end
