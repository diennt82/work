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

#define BTN_CONTINUE_TAG 599

@interface CreateBLEConnection_VController () <CustomIOS7AlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *btnConnect;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;
@property (retain, nonatomic) IBOutlet UITableViewCell *searchAgainCell;
@property (retain, nonatomic) IBOutlet UIView *viewError;

@property (retain, nonatomic) CBPeripheral *selectedPeripheral;
@property (retain, nonatomic) CustomIOS7AlertView *alertView;
@property (retain, nonatomic) NSTimer *timerTimeoutConnectBLE;
@property (nonatomic) BOOL shouldTimeoutProcessing;
@property (nonatomic, retain) UIButton *btnContinue;
@property (nonatomic) BOOL rescanFlag;

@end

@implementation CreateBLEConnection_VController


@synthesize  inProgress;
@synthesize  homeWifiSSID;
@synthesize cameraName = _cameraName;
@synthesize cameraMac = _cameraMac;
@synthesize currentBLEList = _currentBLEList;

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
    
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"hubble_logo"];
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
    
    UIImageView *imageView  = (UIImageView *)[self.viewProgress viewWithTag:575];
    imageView.animationImages = @[[UIImage imageNamed:@"setup_camera_c1"],
                                  [UIImage imageNamed:@"setup_camera_c2"],
                                  [UIImage imageNamed:@"setup_camera_c3"],
                                  [UIImage imageNamed:@"setup_camera_c4"]];
    imageView.animationDuration = 1.5f;
    imageView.animationRepeatCount = 0;
    
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    [imageView startAnimating];
    self.homeWifiSSID = [CameraPassword fetchSSIDInfo];
    NSLog(@"homeWifiSSID: %@", self.homeWifiSSID);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.homeWifiSSID forKey:HOME_SSID];
    [userDefaults synchronize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self createBLEConnectionRescan:FALSE];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *viewControllers = self.navigationController.viewControllers;
	if ([viewControllers indexOfObject:self] == NSNotFound) {
		// View is disappearing because it was popped from the stack
		NSLog(@"View controller was popped --- We are closing down..task_cancelled = YES");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
    else
    {
        
    }
    
    task_cancelled = YES;
    
    //remove delegate
    [BLEConnectionManager getInstanceBLE].delegate = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Actions

- (IBAction)btnConnectTouchUpInsideAction:(id)sender
{
    [[BLEConnectionManager getInstanceBLE].cm stopScan];
    
    if ([BLEConnectionManager getInstanceBLE].state == CONNECTING )
    {
        NSLog(@"BLE is connecting... return.");
        return;
    }
    
    NSLog(@"CreateBLE VC - btnConnectTouchUpInsideAction: %@", self.selectedPeripheral);
    
    [[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:_selectedPeripheral];
    
    [self createHubbleAlertView];
}

- (IBAction)btnContinueTouchUpInsideAction:(id)sender
{
    NSLog(@"CreateBLE VC - btnContinueTouchUpInsideAction - refreshCamBLE");
    [self.viewError removeFromSuperview];
    self.shouldTimeoutProcessing = FALSE;
    [self createBLEConnectionRescan:_rescanFlag];
}

- (void)hubbleItemAction:(id)sender
{
    _isBackPress = YES;
    ConnectionState stateConnectBLE = [BLEConnectionManager getInstanceBLE].state;
    if ( stateConnectBLE != CONNECTED)
    {
        //in state : SCANNING OR IDLE
        _isBackPress = NO;
        [[BLEConnectionManager getInstanceBLE] stopScanBLE];
        [BLEConnectionManager getInstanceBLE].delegate = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        //In State CONNECTED
        //wait for return from delegate,
        //handle it on bleDisconnected
        //disconnect to BLE
        [BLEConnectionManager getInstanceBLE].delegate = nil;
        [[BLEConnectionManager getInstanceBLE] disconnect];
    }
}

- (IBAction)refreshCamBLE:(id)sender
{
    [self createBLEConnectionRescan:TRUE];
}

- (void) handleBack:(id)sender
{
    _isBackPress = YES;
    ConnectionState stateConnectBLE = [BLEConnectionManager getInstanceBLE].state;
    if ( stateConnectBLE != CONNECTED)
    {
        //in state : SCANNING OR IDLE
        _isBackPress = NO;
        [[BLEConnectionManager getInstanceBLE] stopScanBLE];
        [BLEConnectionManager getInstanceBLE].delegate = nil;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        //In State CONNECTED
        //wait for return from delegate,
        //handle it on bleDisconnected
        //disconnect to BLE
        [BLEConnectionManager getInstanceBLE].delegate = nil;
        [[BLEConnectionManager getInstanceBLE] disconnect];
    }
}

- (void)timeoutBLESetupProcessing:(NSTimer *)timer
{
    self.shouldTimeoutProcessing = TRUE;
    
    [self.viewProgress removeFromSuperview];
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
        //[alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Close1", @"Close2", @"Close3", nil]];
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
    label.text = @"Connecting to Camera";
    [demoView addSubview:label];
    [label release];
    
    return demoView;
}

#pragma mark - Methods

- (void)createBLEConnectionRescan: (BOOL)rescanFlag
{
    NSLog(@"CreateBLE VC - createBLEConnectionRescan: %d", rescanFlag);
    
    [self clearDataBLEConnection];
    
    if (_currentBLEList)
    {
        [_currentBLEList removeAllObjects];
    }
    
    [self.ib_tableListBLE reloadData];
    
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    
    if (rescanFlag)
    {
        [[BLEConnectionManager getInstanceBLE] reScan];
    }
    else
    {
        [[BLEConnectionManager getInstanceBLE] scan];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scanCameraBLEDone) userInfo:nil repeats:NO];
    
    if (_timerTimeoutConnectBLE != nil)
    {
        [self.timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    self.timerTimeoutConnectBLE = [NSTimer scheduledTimerWithTimeInterval:5*60
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
    if (task_cancelled == TRUE)
    {
        return;
    }
    
    if ([_currentBLEList count] == 0) //NO camera found
    {
        NSLog(@"No BLE device found! schedule next check ");
        
        if (_shouldTimeoutProcessing)
        {
            NSLog(@"CreateBLEConnection_VC - scanCameraBLEDone - Timeout");
        }
        else
        {
            [NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:self
                                           selector:@selector(scanCameraBLEDone)
                                           userInfo:nil
                                            repeats:NO];
        }
        //Check again
    }
    else
    {
        //NOTE: The list is filtered while scanning, only known devices are shown here
        
        self.rescanFlag = TRUE;
        
        [[BLEConnectionManager getInstanceBLE].cm stopScan];
        
        if ([_currentBLEList count] ==1) //connect directly
        {
            //Update UI
            [self.viewProgress removeFromSuperview];
            [self.ib_lableStage setText:@"Select a device to connect"];
            [self.ib_tableListBLE reloadData];
            
            self.btnConnect.enabled = YES;
            self.selectedPeripheral = (CBPeripheral *)[_currentBLEList objectAtIndex:0];
            NSLog(@"Found 1 %@, connect now", self.selectedPeripheral.name );
            
            [[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:_selectedPeripheral];
            
            [self createHubbleAlertView];
        }
        else //more than 2
        {
            NSLog(@"Found more than 1 valid devices -> Show lists");
            
            //Update UI
            [self.viewProgress removeFromSuperview];
            
            [self.ib_lableStage setText:@"Select a device to connect"];
            
            [self.ib_tableListBLE reloadData];
            self.btnConnect.enabled = YES;
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
#if 1
    //[self.viewProgress removeFromSuperview];
#else
    [self.ib_Indicator setHidden:YES];
    [self.ib_lableStage setText:@"Can't connect to BLE, please press refresh button"];
#endif
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

- (void)viewDidUnload
{
    //    [self setIb_tableListBLE:nil];
    //    [self setIb_Indicator:nil];
    //    [self setIb_RefreshBLE:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark -

-(void) dealloc
{
    [homeWifiSSID release];
    [_ib_tableListBLE release];
    [_btnConnect release];
    [_viewProgress release];
    [_searchAgainCell release];
    [_alertView release];
    [_viewError release];
    [_timerTimeoutConnectBLE release];
    [super dealloc];
}

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
        //do nothing
        if (_timerTimeoutConnectBLE != nil)
        {
            [self.timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }

        NSLog(@"CreateBLEConnection_VC - bleDisconnected - _isBackPress = TRUE");
    }
}

- (void) didConnectToBle:(CBUUID*) service_id
{
    NSLog(@"BLE device connected - performSelector now");
    
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
        
        step04ViewController = [[EditCamera_VController alloc]
                                initWithNibName:@"EditCamera_VController" bundle:nil];
        
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

-(void) moveToNextStep
{
    //First time enter, try to flush BLE buffer
    
    // FLUSH ---
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
        return;
    }
    
    NSLog(@"Now, send command get version");
    //first get mac address of camera
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_VERSION withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    
    NSDate * date;
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
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
    
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        NSLog(@"sendCommandGetUDID:  wait for result ");
        
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    return TRUE;
}

- (void)clearDataBLEConnection
{
    [[BLEConnectionManager getInstanceBLE].listBLEs removeAllObjects];
    [[BLEConnectionManager getInstanceBLE].cm stopScan];
    [BLEConnectionManager getInstanceBLE].state = IDLE;
}

- (void) didReceiveBLEList:(NSMutableArray *)bleLists
{
    _currentBLEList = bleLists;
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 1;
    }
    
    return [_currentBLEList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
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
        
        CBPeripheral *peripheral = [_currentBLEList objectAtIndex:indexPath.row];
        cell.lblName.text = peripheral.name;
        
        return cell;
    }
    else
    {
        return _searchAgainCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        [self refreshCamBLE:nil];
    }
    else
    {
        self.btnConnect.enabled = YES;
        self.selectedPeripheral = (CBPeripheral *)[[BLEConnectionManager getInstanceBLE].listBLEs objectAtIndex:indexPath.row];
    }
}

@end