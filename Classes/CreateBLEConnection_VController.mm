//
//  CreateBLEConnection_VController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "CreateBLEConnection_VController.h"
#import "PublicDefine.h"
#import "BLEConnectionCell.h"
#import "CustomIOS7AlertView.h"
#import "Camera.h"
#import "Step_04_ViewController.h"
#import "MBProgressHUD.h"
#import "define.h"
#import "UIView+Custom.h"

#define BTN_CONTINUE_TAG    599
#define BLE_TIMEOUT_PROCESS 1.5*60
#define SETUP_UNKNOW        0
#define SETUP_BLE           1
#define SETUP_LAN           2

@interface CreateBLEConnection_VController () <CustomIOS7AlertViewDelegate, BonjourDelegate>

@property (retain, nonatomic) IBOutlet UIButton *btnConnect;

@property (retain, nonatomic) IBOutlet UITableViewCell *searchAgainCell;
@property (retain, nonatomic) IBOutlet UIView *viewError;
@property (retain, nonatomic) IBOutlet UIView *viewPairNDetecting;

@property (retain, nonatomic) CBPeripheral *selectedPeripheral;
@property (retain, nonatomic) CustomIOS7AlertView *alertView;
@property (retain, nonatomic) NSTimer *timerTimeoutConnectBLE;
@property (retain, nonatomic) NSTimer *timerScanCameraBLEDone;
@property (nonatomic) BOOL shouldTimeoutProcessing;
@property (nonatomic, retain) UIButton *btnContinue;
@property (nonatomic) BOOL rescanFlag;
@property (nonatomic, retain) UIView *viewSearching;
@property (nonatomic) BOOL isNotFirstTime;
@property (nonatomic, retain) NSMutableArray *arrayFocus73;
@property (nonatomic) BOOL isScanning;
@property (nonatomic, retain) CamProfile *selectedCamProfile;
@property (retain, nonatomic) NSThread *threadBonjour;
@property (nonatomic) NSInteger setupType;

@end

@implementation CreateBLEConnection_VController

@synthesize  inProgress;
@synthesize  homeWifiSSID;
@synthesize cameraName = _cameraName;
@synthesize cameraMac = _cameraMac;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        showProgressNextTime= FALSE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self xibDefaultLocalization];
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [self.btnConnect setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnConnect setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    self.btnConnect.enabled = NO;
    
    self.btnContinue = (UIButton *)[_viewError viewWithTag:BTN_CONTINUE_TAG];
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    [self.btnContinue addTarget:self action:@selector(btnContinueTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentBLEList = [[NSMutableArray alloc] init];
    
    
    self.viewSearching = (UIView *)[self.viewPairNDetecting viewWithTag:675];
    
    UIImageView *imgView  = (UIImageView *)[_viewSearching viewWithTag:575];
    imgView.animationImages = @[[UIImage imageNamed:@"setup_camera_c1"],
                                  [UIImage imageNamed:@"setup_camera_c2"],
                                  [UIImage imageNamed:@"setup_camera_c3"],
                                  [UIImage imageNamed:@"setup_camera_c4"]];
    imgView.animationDuration = 1.5f;
    imgView.animationRepeatCount = 0;
    
    [self.view addSubview:_viewPairNDetecting];
    [self.view bringSubviewToFront:_viewPairNDetecting];
    
    [imgView startAnimating];
    

    self.homeWifiSSID = [CameraPassword fetchSSIDInfo];
    NSLog(@"homeWifiSSID: %@", self.homeWifiSSID);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.homeWifiSSID forKey:HOME_SSID];
    [userDefaults synchronize];
    
    CAMERA_TAG tag = (CAMERA_TAG)[[userDefaults objectForKey:SET_UP_CAMERA_TAG] intValue];
    UIImage *iconImage = [self convertToCamaraImage:tag];
    [self.cameraIcon setImage:iconImage];
}

- (void)xibDefaultLocalization
{
    [[self.view viewWithTag:10] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_CreateBLEConnection_label_select_camera", nil, [NSBundle mainBundle], @"Select Camera", nil)];
    [self.btnConnect setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step03_button_yes", nil, [NSBundle mainBundle], @"Yes", nil)];
    
    [[self.viewPairNDetecting viewWithTag:10] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_CreateBLEConnection_label_detectint_the_camera", nil, [NSBundle mainBundle], @"Detecting the Camera", nil)];
    [[self.viewPairNDetecting viewWithTag:11] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_CreateBLEConnection_label_press_and_hold", nil, [NSBundle mainBundle], @"Press and hold the button marked 'PAIR' for 3 seconds ", nil)];
    [[self.viewPairNDetecting viewWithTag:12] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_CreateBLEConnection_label_this_may_takeup", nil, [NSBundle mainBundle], @"This may take up to a minute", nil)];
    
    [[self.viewError viewWithTag:10] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_CreateBLEConnection_label_unable_to_detect_camera", nil, [NSBundle mainBundle], @"Unable to Detect Camera", nil)];
    [[self.viewError viewWithTag:11] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_CreateBLEConnection_label_timout", nil, [NSBundle mainBundle], @"Timeout", nil)];
    [[self.viewError viewWithTag:599] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_CreateBLEConnection_button_retry", nil, [NSBundle mainBundle], @"Retry", nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.viewError.frame = rect;
        //self.viewProgress.frame = rect;
    }
    
    if (_cameraType == SETUP_CAMERA_FOCUS73)
    {
        if (_arrayFocus73.count == 0 && _currentBLEList.count == 0)
        {
            [self createBLEConnectionRescan:FALSE];
            
            if (_cameraType == SETUP_CAMERA_FOCUS73)
            {
                [self startScanningWithBonjour];
            }
        }
    }
    else
    {
        if (_currentBLEList.count == 0)
        {
            [self createBLEConnectionRescan:FALSE];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s", __FUNCTION__);
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
	if ([viewControllers indexOfObject:self] == NSNotFound) {
		// View is disappearing because it was popped from the stack
		NSLog(@"View controller was popped --- We are closing down..task_cancelled = YES");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
    
    task_cancelled = YES;
    
    //remove delegate
    [BLEConnectionManager getInstanceBLE].delegate = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Actions

- (IBAction)btnConnectTouchUpInsideAction:(id)sender
{
    if (_setupType == SETUP_LAN)
    {
        NSLog(@"Load step 4");
        //Load the next xib
        Step_04_ViewController *step04ViewController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            step04ViewController = [[Step_04_ViewController alloc]
                                    initWithNibName:@"Step_04_ViewController_ipad" bundle:nil];
        }
        else
        {
            step04ViewController = [[Step_04_ViewController alloc]
                                    initWithNibName:@"Step_04_ViewController" bundle:nil];
        }
        
        // Pass the selected object to the new view controller.
        step04ViewController.camProfile = _selectedCamProfile;
        
        // Push the view controller.
        [self.navigationController pushViewController:step04ViewController animated:YES];
        [step04ViewController release];
    }
    else
    {
        [[BLEConnectionManager getInstanceBLE] stopScanBLE];
        
        if ([BLEConnectionManager getInstanceBLE].state == CONNECTING )
        {
            NSLog(@"%s BLE is connecting... return.", __FUNCTION__);
            return;
        }
        
        NSLog(@"%s %@", __FUNCTION__, self.selectedPeripheral);
        
        [[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:_selectedPeripheral];
        
        [self createHubbleAlertView];
    }
}

- (IBAction)btnContinueTouchUpInsideAction:(id)sender
{
    NSLog(@"CreateBLE VC - btnContinueTouchUpInsideAction - refreshCamBLE");
    [self.viewError removeFromSuperview];
    self.shouldTimeoutProcessing = FALSE;
    self.setupType = SETUP_UNKNOW;
    
    [self createBLEConnectionRescan:_rescanFlag];
    
    if (_cameraType == SETUP_CAMERA_FOCUS73)
    {
        [self rescanBonjour];
    }
}

- (void)hubbleItemAction:(id)sender
{
    _isBackPress = YES;
    ConnectionState stateConnectBLE = [BLEConnectionManager getInstanceBLE].state;
    NSLog(@"CreateBLE VC - hubbleItemAction - stateConnectBLE: %d", stateConnectBLE);
    
    if (_cameraType == SETUP_CAMERA_FOCUS73)
    {
        [self cancelBonjourThread];
    }
    
    if ( stateConnectBLE != CONNECTED)
    {
        //in state : SCANNING OR IDLE
        _isBackPress = NO;
        [[[BLEConnectionManager getInstanceBLE] uartPeripheral] didDisconnect];
        
        self.shouldTimeoutProcessing = TRUE;
        
        if (_timerScanCameraBLEDone)
        {
            [self.timerScanCameraBLEDone invalidate];
            self.timerScanCameraBLEDone = nil;
        }
        
        if (_timerTimeoutConnectBLE)
        {
            [self.timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        [[BLEConnectionManager getInstanceBLE] stopScanBLE];
        [BLEConnectionManager getInstanceBLE].delegate = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        hub.labelText = @"Disconnecting BLE...";
        /*
         * -- In State CONNECTED --
         * wait for return from delegate,
         * handle it on bleDisconnected
         * disconnect to BLE
         */
        
        [BLEConnectionManager getInstanceBLE].needReconnect = FALSE;
        [BLEConnectionManager getInstanceBLE].delegate = self;
        [[BLEConnectionManager getInstanceBLE] disconnect];
    }
}

- (IBAction)refreshCamBLE:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    self.selectedPeripheral = nil;
    self.selectedCamProfile = nil;
    self.btnConnect.enabled = NO;
    self.setupType = SETUP_UNKNOW;
    self.shouldTimeoutProcessing = FALSE;
    
    [self createBLEConnectionRescan:TRUE];
    
    if (_cameraType == SETUP_CAMERA_FOCUS73)
    {
        self.viewPairNDetecting.hidden = NO;
        [self.view addSubview:_viewPairNDetecting];
        [self.view bringSubviewToFront:_viewPairNDetecting];
        
        [self rescanBonjour];
    }
}

- (void)timeoutBLESetupProcessing:(NSTimer *)timer
{
    NSLog(@"%s", __FUNCTION__);
    
    self.shouldTimeoutProcessing = TRUE;
    
    if (_timerScanCameraBLEDone)
    {
        [self.timerScanCameraBLEDone invalidate];
        self.timerScanCameraBLEDone = nil;
    }
    
    [[BLEConnectionManager getInstanceBLE] stopScanBLE];
    

    [self.viewPairNDetecting removeFromSuperview];
    [self customIOS7dialogButtonTouchUpInside:_alertView clickedButtonAtIndex:0];
    
    [self.view addSubview:_viewError];
    [self.view bringSubviewToFront:_viewError];
}

#pragma mark - Hubble alert view & delegate

- (void)createHubbleAlertView
{
    // Here we need to pass a full frame
    
    if (_alertView == nil)
    {
        self.alertView = [[CustomIOS7AlertView alloc] init];
        // Add some custom content to the alert view
        [_alertView setContainerView:[self createDemoView]];
        
        // Modify the parameters

        [_alertView setButtonTitles:NULL];
        [_alertView setDelegate:self];
        
        // You may use a Block, rather than a delegate.
        [_alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
            [alertView close];
        }];
        
        [_alertView setUseMotionEffects:true];
    }

    // And launch the dialog
    [_alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    [alertView close];
}

- (UIView *)createDemoView
{
    UIView *demoView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 140)] autorelease];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 35, 30, 30)];// autorelease];
    [imageView setImage:[UIImage imageNamed:@"loader_a"]];
    
    imageView.animationImages = @[[UIImage imageNamed:@"loader_a"],
                                  [UIImage imageNamed:@"loader_b"],
                                  [UIImage imageNamed:@"loader_c"],
                                  [UIImage imageNamed:@"loader_d"],
                                  [UIImage imageNamed:@"loader_e"],
                                  [UIImage imageNamed:@"loader_f"]];
    imageView.animationRepeatCount = 0;
    imageView.animationDuration = 1.5f;
    [imageView startAnimating];
    
    [demoView addSubview:imageView];
    
    [imageView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 200, 21)];// autorelease];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedStringWithDefaultValue(@"connecting_to_amera", nil, [NSBundle mainBundle], @"Connecting to Camera", nil);
    [demoView addSubview:label];
    [label release];
    
    return demoView;
}

#pragma mark - Methods

- (void)createBLEConnectionRescan: (BOOL)rescanFlag
{
    NSLog(@"%s rescanFlag %d", __FUNCTION__, rescanFlag);
    
    //if (rescanFlag)
    {
    }
    //else
    {
        [self.view addSubview:_viewPairNDetecting];
        [self.view bringSubviewToFront:_viewPairNDetecting];
    }
    
    [self clearDataBLEConnection];
    
    if (_currentBLEList)
    {
        [_currentBLEList removeAllObjects];
    }
    
    [self.ib_tableListBLE reloadData];

    task_cancelled = NO;
    self.shouldTimeoutProcessing = NO;
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [BLEConnectionManager getInstanceBLE].needReconnect = YES;
    
    if (rescanFlag)
    {
        [[BLEConnectionManager getInstanceBLE] reScan];
    }
    else
    {
        [[BLEConnectionManager getInstanceBLE] scan];
    }
    
    if (_timerScanCameraBLEDone)
    {
        [self.timerScanCameraBLEDone invalidate];
        self.timerScanCameraBLEDone = nil;
    }
    
    self.timerScanCameraBLEDone = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scanCameraBLEDone) userInfo:nil repeats:NO];
    
    if (_timerTimeoutConnectBLE != nil)
    {
        [self.timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    self.timerTimeoutConnectBLE = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                                   target:self
                                                                 selector:@selector(timeoutBLESetupProcessing:)
                                                                 userInfo:nil
                                                                  repeats:NO];
}

- (void)checkConnectionToCamera:(NSTimer *)expired // just clear waring
{
    if (expired != nil)
    {
        [expired invalidate];
        expired = nil;
    }
}

- (void)scanCameraBLEDone
{
    NSLog(@"%s - task_cancelled: %d, - _currentBLEList.count: %d, - shouldTimeoutProcessing: %d, isMT:%d", __FUNCTION__, task_cancelled, _currentBLEList.count, _shouldTimeoutProcessing, [NSThread currentThread].isMainThread);
    
    if (task_cancelled == TRUE   ||
        _shouldTimeoutProcessing ||
        _setupType != SETUP_UNKNOW)
    {
        return;
    }
    
    self.viewSearching.hidden = NO;
    
    if (_cameraType == SETUP_CAMERA_FOCUS73)
    {
        if (_threadBonjour && !_threadBonjour.isExecuting)
        {
            NSLog(@"%s Stop scanning Bonjour services.", __FUNCTION__);
            
            if (_arrayFocus73.count > 0)
            {
                NSLog(@"%s Got some Bonjour services.", __FUNCTION__);
                
                if (_timerTimeoutConnectBLE)
                {
                    if ([_timerTimeoutConnectBLE isValid])
                    {
                        [_timerTimeoutConnectBLE invalidate];
                    }
                }
                
                self.shouldTimeoutProcessing = TRUE;
                
                if (_timerScanCameraBLEDone)
                {
                    [self.timerScanCameraBLEDone invalidate];
                    self.timerScanCameraBLEDone = nil;
                }
                
                [[BLEConnectionManager getInstanceBLE] stopScanBLE];
                
                self.viewPairNDetecting.hidden = YES;
                [self.viewPairNDetecting removeFromSuperview];
                [self.ib_lableStage setText:NSLocalizedStringWithDefaultValue(@"select_a_device_to_connect", nil, [NSBundle mainBundle], @"Select a device to connect", nil)];
                [self.ib_tableListBLE reloadData];
                
                if (_arrayFocus73.count == 1)
                {
                    self.btnConnect.enabled = YES;
                    self.selectedCamProfile = _arrayFocus73[0];
                    self.setupType = SETUP_LAN;
                    [self btnConnectTouchUpInsideAction:nil];
                    
                    NSLog(@"%s Got a Bonjour service.", __FUNCTION__);
                }
                
                return;
            }
            else
            {
                NSLog(@"%s There is currently no Bonjour service.", __FUNCTION__);
            }
        }
        else
        {
            NSLog(@"%s Scanning Bonjour services.", __FUNCTION__);
        }
    }
    
    if ([_currentBLEList count] == 0) //NO camera found
    {
        NSLog(@"No BLE device found! schedule next check ");
        
        self.timerScanCameraBLEDone = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                       target:self
                                                                     selector:@selector(scanCameraBLEDone)
                                                                     userInfo:nil
                                                                      repeats:NO];
        //Check again
    }
    else
    {
        //NOTE: The list is filtered while scanning, only known devices are shown here
        
        self.rescanFlag = TRUE;
        
        [[BLEConnectionManager getInstanceBLE] stopScanBLE];
        
        [self cancelBonjourThread];
        
        [self.viewPairNDetecting removeFromSuperview];
        [self.ib_lableStage setText:NSLocalizedStringWithDefaultValue(@"select_a_device_to_connect", nil, [NSBundle mainBundle], @"Select a device to connect", nil)];
        [self.ib_tableListBLE reloadData];
        
        if ([_currentBLEList count] == 1) //connect directly
        {
            //Update UI
            //[self.viewProgress removeFromSuperview];
            self.selectedPeripheral = (CBPeripheral *)_currentBLEList[0];
            NSLog(@"Found 1 %@, connect now", self.selectedPeripheral.name );
            
            //[[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:_selectedPeripheral];
            //[self createHubbleAlertView];
            //self.shouldTimeoutProcessing = TRUE;
            self.setupType = SETUP_BLE;
            self.btnConnect.enabled = YES;
            [self btnConnectTouchUpInsideAction:nil];
        }
        else //more than 2
        {
            NSLog(@"Found more than 1 valid devices -> Show lists");
            
            //Update UI
            // [self.viewProgress removeFromSuperview];
            //[self.viewPairNDetecting removeFromSuperview];
            //[self.ib_lableStage setText:NSLocalizedStringWithDefaultValue(@"select_a_device_to_connect", nil, [NSBundle mainBundle], @"Select a device to connect", nil)];
            //[self.ib_tableListBLE reloadData];
            //self.btnConnect.enabled = YES;
        }
    }
}

- (void)dismissIndicator
{
    if (_timerTimeoutConnectBLE)
    {
        [_timerTimeoutConnectBLE invalidate];
        [self setTimerTimeoutConnectBLE:nil];
    }
}


/* This is called when BLE is connected & RX, TX characteristic is found
 */
- (void)updateUIConnection:(NSTimer *)info
{
    if ([BLEConnectionManager getInstanceBLE].state == CONNECTED)
    {
        /* Start sending commands now */
        [self moveToNextStep];
        
        //[self.ib_tableListBLE setExclusiveTouch:YES];
    }
    else
    {
        NSLog(@"updateUIConnection : BLE state is %d, not CONNECTED", [BLEConnectionManager getInstanceBLE].state);
    }
}

#pragma mark -

-(void) dealloc
{
    NSLog(@"%s", __FUNCTION__);
    
    [homeWifiSSID release];
    [_ib_tableListBLE release];
    [_btnConnect release];
  //  [_viewProgress release];
    [_searchAgainCell release];
    [_alertView release];
    [_viewError release];
    [_timerTimeoutConnectBLE release];
    [_viewPairNDetecting release];
    [_threadBonjour release];
    [super dealloc];
}

#if 0
-(void) handleEnteredBackground
{
    showProgressNextTime = TRUE;
}

-(void) becomeActive
{
    if (showProgressNextTime)
    {
        NSLog(@"cshow progress 03");
        [self showProgress:nil];
    }
    
    task_cancelled = NO;
    [self checkConnectionToCamera:nil];
}

-(void) showProgress:(NSTimer *) exp
{
    NSLog(@"show progress ");
    
    if (self.inProgress != nil)
    {
        NSLog(@"show progress 01 ");
        self.inProgress.hidden = NO;
        [self.view bringSubviewToFront:self.inProgress];
    }
}

- (void) hideProgess
{
    NSLog(@"hide progress");
    
    if (self.inProgress != nil)
    {
        self.inProgress.hidden = YES;
    }
}
#endif

#pragma mark - BLEConnectionManagerDelegate

-(void) bleDisconnected
{
    NSLog(@"CreateBLEConnection_VC - bleDisconnected - _isBackPress: %d, -shouldTimeout: %d", _isBackPress, _shouldTimeoutProcessing);
    
    if (!_isBackPress)
    {
        if (_shouldTimeoutProcessing)
        {
            NSLog(@"CreateBLEConnection_VC - bleDisconnected - Timeout, popup the error view");
        }
        else
        {
            //if button back don't press
            NSLog(@"BLE device is DISCONNECTED - Reconnect  ");
            NSDate * date;
            date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
            [[NSRunLoop currentRunLoop] runUntilDate:date];
            
            [[BLEConnectionManager getInstanceBLE] reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
        }
    }
    else
    {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        
        if (_timerTimeoutConnectBLE != nil)
        {
            [self.timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        NSLog(@"%s Killing BLE.", __FUNCTION__);
        [BLEConnectionManager getInstanceBLE].delegate = nil;
        [[BLEConnectionManager getInstanceBLE] stopScanBLE];

        [self.navigationController popViewControllerAnimated:YES];
        
        NSLog(@"CreateBLEConnection_VC - bleDisconnected - _isBackPress = TRUE");
    }
}

- (void) didConnectToBle:(CBUUID*) service_id
{
    NSLog(@"%s - performSelector now", __FUNCTION__);
    
    if (_timerScanCameraBLEDone)
    {
        [_timerScanCameraBLEDone invalidate];
        self.timerScanCameraBLEDone = nil;
    }
    
    [self performSelectorOnMainThread:@selector(updateUIConnection:) withObject:nil
                        waitUntilDone:NO  ];
}

- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera
{
    
}

- (void) didReceiveData:(NSString *)stringResponse
{
    NSLog(@"Receive string %@", stringResponse);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (stringResponse == nil)
    {
        //check which step it is
        NSString * udid = [userDefaults objectForKey:CAMERA_UDID];
        NSString *  version = [userDefaults objectForKey:FW_VERSION];
        
        if (udid != nil)
        {
            if (version !=  nil)
            {
                NSLog(@"Receive nil string from no where.");
                return;
            }
            else
            {
                //Retry GetVersion
                [self sendCommandGetVersion];
            }
        }
        else
        {
            //Retry Camera UDID & version
            if ( [self sendCommandGetUDID:nil])
            {
                
                [self sendCommandGetVersion];
            }
        }
    }
    else if ([stringResponse rangeOfString:GET_VERSION].location != NSNotFound)
    {
        [self customIOS7dialogButtonTouchUpInside:_alertView clickedButtonAtIndex:0];
        //sucucessfull when writing version
        //diss miss statusDialog
        NSLog(@"CreateBLEConnection_VC -get version successfull: %@", stringResponse);
        
        NSRange colonRange = [stringResponse rangeOfString:@": "];
        
        if (colonRange.location != NSNotFound)
        {
            NSString *fwVersion = [[stringResponse componentsSeparatedByString:@": "] objectAtIndex:1];
            
            if ([fwVersion isEqualToString:@"-1"])
                fwVersion = @"01_007_02";
            
            [userDefaults setObject:fwVersion forKey:FW_VERSION];
            [userDefaults setObject:self.cameraName forKey:CAMERA_SSID];
            [userDefaults synchronize];
        }
        else
        {
            NSLog(@"CreateBLEConnection_VC - get version NOT found");
        }
        
        NSLog(@"Load step 40 - EditCamera_VC");
        //Load the next xib
        EditCamera_VController *step04ViewController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            step04ViewController = [[EditCamera_VController alloc]
                                    initWithNibName:@"EditCamera_VController_iPad" bundle:nil];
        }
        else
        {
            step04ViewController = [[EditCamera_VController alloc]
                                    initWithNibName:@"EditCamera_VController" bundle:nil];
        }
        
        step04ViewController.cameraMac = self.cameraMac;
        step04ViewController.cameraName = self.cameraName;
        
        NSLog(@"Load step 41 - EditCamera_VC");
        [self.navigationController pushViewController:step04ViewController animated:NO];
        
        [step04ViewController release];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        if (_timerTimeoutConnectBLE)
        {
            [self.timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        if (_timerScanCameraBLEDone)
        {
            [self.timerScanCameraBLEDone invalidate];
            self.timerScanCameraBLEDone = nil;
        }
    }
    else if (  [stringResponse rangeOfString:GET_UDID].location != NSNotFound)
    {
        //get_udid: 01008344334C32B0A0VFFRBSVA
        NSString *stringUDID = [stringResponse substringFromIndex:GET_UDID.length + 2];
        NSLog(@"Get UDID successfully - udid: %@", stringUDID);
        
        self.cameraMac = [stringUDID substringWithRange:NSMakeRange(6, 12)];
        
        /*
         * Make sure a valid camera name.
         */

        if (_selectedPeripheral != nil && _selectedPeripheral.name != nil)
        {
            self.cameraName = _selectedPeripheral.name;
        }
        else
        {
            NSString *cameraNameFinal = [NSString stringWithFormat:@"%@%@%@", DEFAULT_SSID_HD_PREFIX, [stringUDID substringWithRange:NSMakeRange(2, 4)], [_cameraMac substringFromIndex:6]];
            self.cameraName = cameraNameFinal;
        }
        
        [userDefaults setObject:self.cameraMac forKey:@"CameraMacSave"];
        [userDefaults setObject:stringUDID forKey:CAMERA_UDID];
        [userDefaults synchronize];
    }
    else
    {
        NSLog(@"CreateBLEConnectionVC - didReceiveData - Unknown error");
    }
}

- (void)moveToNextStep
{
    //First time enter, try to flush BLE buffer

    [BLEConnectionManager getInstanceBLE].delegate = self;
    
    if ([BLEConnectionManager getInstanceBLE].state == CONNECTED)
    {
        NSLog(@"Clear Udid");
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:CAMERA_UDID];
        [userDefaults synchronize];
        
        if ( [self sendCommandGetUDID:nil])
        {
            [self sendCommandGetVersion];
        }
    }
    else
    {
        [self dismissIndicator];
    }
}

- (void)sendCommandGetVersion
{
    if ([BLEConnectionManager getInstanceBLE].state != CONNECTED)
    {
        NSLog(@"%s state != CONNECTED", __FUNCTION__);
        return;
    }
    
    NSLog(@"Now, send command get version");
    //first get mac address of camera
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_VERSION withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    
    NSDate * date;
    BOOL debug = TRUE;
    
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
        if (debug) {
            debug = FALSE;
            NSLog(@"%s Peripheral is busy. Maybe wait forever...", __FUNCTION__);
        }
    }
}


- (BOOL)sendCommandGetUDID:(NSTimer *)info
{
    NSLog(@"now, Send command get udid");
    
    if ([BLEConnectionManager getInstanceBLE].state != CONNECTED)
    {
        NSLog(@"sendCommandGetUDID:  BLE disconnected - ");
        
        return FALSE;
    }
    
    //first get version of camera
    [BLEConnectionManager getInstanceBLE].delegate = self;
    
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_UDID withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    NSDate * date;
    
    BOOL debugLog = TRUE;
    
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        if (debugLog)
        {
            NSLog(@"%s Peripheral is busy. Waiting for result...", __FUNCTION__);
            debugLog = FALSE;
        }
        
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    return TRUE;
}

- (void)clearDataBLEConnection
{
    [[BLEConnectionManager getInstanceBLE].listBLEs removeAllObjects];
    [[BLEConnectionManager getInstanceBLE] stopScanBLE];
    [BLEConnectionManager getInstanceBLE].state = IDLE;
}

- (void) didReceiveBLEList:(NSMutableArray *)bleLists
{
    _currentBLEList = bleLists;
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#if 1
    return section==0?_currentBLEList.count:(section==1?_arrayFocus73.count:1);
#else
    if (section == 2)
    {
        return 1;
    }
    
    if (section == 1)
    {
        return _arrayFocus73.count;
    }
    
    return _currentBLEList.count;
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1)
    {
        static NSString *CellIdentifier = @"BLEConnectionCell";
        BLEConnectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BLEConnectionCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            if ([curObj isKindOfClass:[BLEConnectionCell class]])
            {
                cell = (BLEConnectionCell *)curObj;
                break;
            }
        }
        
        if (indexPath.section == 0)
        {
            CBPeripheral *peripheral = _currentBLEList[indexPath.row];
            cell.lblName.text = peripheral.name;
        }
        else
        {
            CamProfile *cp = _arrayFocus73[indexPath.row];
            cell.lblName.text = cp.name;
        }
        
        return cell;
    }
    else
    {
        return _searchAgainCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0)
    {
        [self refreshCamBLE:nil];
    }
    else
    {
        self.btnConnect.enabled = YES;
        
        if (indexPath.section == 0)
        {
            self.setupType = SETUP_BLE;
            self.selectedPeripheral = (CBPeripheral *)[BLEConnectionManager getInstanceBLE].listBLEs[indexPath.row];
        }
        else
        {
            self.setupType = SETUP_LAN;
            self.selectedCamProfile = _arrayFocus73[indexPath.row];
        }
    }
}

- (UIImage *)convertToCamaraImage:(CAMERA_TAG)cameraTad {
    switch (cameraTad) {
        case MBP_83_TAG:
            return [UIImage imageNamed:@"camera_ble2"];
        case MBP_85_TAG:
            return [UIImage imageNamed:@"blesetup_focus85"];
        case SCOUT_73_TAG:
            return [UIImage imageNamed:@"camera_scout85"];
        default:
            break;
    }
    return nil;
}

#pragma mark - Bonjour flow

- (void)startScanningWithBonjour
{
    self.threadBonjour = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(scanWithBonjour)
                                                   object:nil];
    [_threadBonjour start];
}

-(void) scanWithBonjour
{
    @autoreleasepool
    {
        self.isScanning = TRUE;
        // When use autoreleseapool, no need to call autorelease.
        Bonjour *bonjour = [[Bonjour alloc] initSetupWith:nil];
        [bonjour setDelegate:self];
        
        [bonjour startScanLocalWiFi];
        
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        
        while (bonjour.isSearching)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        
        self.arrayFocus73 = [NSMutableArray arrayWithArray:bonjour.cameraList];
        self.isScanning = FALSE;
        
        NSLog(@"%s Scanning Bonjour completely.", __FUNCTION__);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!_timerScanCameraBLEDone || ![_timerScanCameraBLEDone isValid])
            {
                [self scanCameraBLEDone];
            }
        });
        
        [bonjour release];
        
        //[NSThread exit];
    }
    
    [NSThread exit];
}

- (void)rescanBonjour
{
    if (!_isScanning)
    {
        if (_arrayFocus73 && _arrayFocus73.count > 0)
        {
            [_arrayFocus73 removeAllObjects];
            [self.ib_tableListBLE reloadData];
        }
        
        [self startScanningWithBonjour];
    }
}

- (void)cancelBonjourThread
{
    if (_threadBonjour && _threadBonjour.isExecuting)
    {
        [_threadBonjour cancel];
    }
}

#pragma  mark Bongour delete

- (void)bonjourReturnCameraListAvailable:(NSMutableArray *)cameraList
{
}

@end