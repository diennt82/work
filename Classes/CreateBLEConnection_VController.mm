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

@interface CreateBLEConnection_VController () <CustomIOS7AlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *btnConnect;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;
@property (retain, nonatomic) IBOutlet UITableViewCell *searchAgainCell;

@property (retain, nonatomic) CBPeripheral *selectedPeripheral;
@property (retain, nonatomic) CustomIOS7AlertView *alertView;

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
#if 1
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
#else
    self.navigationItem.title = @"Connect to camera BLE";
//    self.navigationItem.backBarButtonItem =
//    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
//                                                                              @"Back", nil)
//                                      style:UIBarButtonItemStyleBordered
//                                     target:nil
//                                     action:nil] autorelease];
    
    
    _currentBLEList = [[NSMutableArray alloc] init];
    
    
    //Override back button of Navigation controller
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(handleBack:)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.ib_lableStage setText:@"Scanning for BLE..."];
    [self.ib_RefreshBLE setEnabled:NO];
    
    [self clearDataBLEConnection];
    
    if (_currentBLEList)
    {
        [_currentBLEList removeAllObjects];
    }
    [self.ib_tableListBLE reloadData];
    
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE] scan];
    
    
    task_cancelled = NO;
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(scanCameraBLEDone)
                                   userInfo:nil
                                    repeats:NO];
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

    NSLog(@"btnConnectTouchUpInsideAction: %@", self.selectedPeripheral);
    
    [[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:_selectedPeripheral];
    
    [self createHubbleAlertView];
}

#pragma mark - Hubble alert view & delegate

- (void)createHubbleAlertView
{
    // Here we need to pass a full frame
    
//    if (_alertView == nil)
//    {
//        self.alertView = [[CustomIOS7AlertView alloc] init];
//    }
    
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoView]];
    
    // Modify the parameters
    //[alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonTitles:NULL];
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
    
    self.alertView = alertView;
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    [alertView close];
}

- (UIView *)createDemoView
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 140)];// autorelease];
    
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
    
    [demoView addSubview:imageView];
    
    [imageView startAnimating];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 200, 21)];// autorelease];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Searching for Camera";
    [demoView addSubview:label];
    
    return demoView;
}


#pragma mark - Methods

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

#if 1
- (IBAction)refreshCamBLE:(id)sender
{
    
    [self clearDataBLEConnection];
    
    if (_currentBLEList)
    {
        [_currentBLEList removeAllObjects];
    }
    [self.ib_tableListBLE reloadData];
    
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE] reScan];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scanCameraBLEDone) userInfo:nil repeats:NO];
}

#else
- (IBAction)refreshCamBLE:(id)sender {
    
    [self clearDataBLEConnection];
    
    if (_currentBLEList)
    {
        [_currentBLEList removeAllObjects];
    }
    [self.ib_tableListBLE reloadData];
    
    
    [self.ib_RefreshBLE setEnabled:NO];
    [self.ib_Indicator setHidden:NO];
    
    [self.ib_lableStage setText:@"Scanning for BLE..."];
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE] reScan];
    
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scanCameraBLEDone) userInfo:nil repeats:NO];
}
#endif

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
#if 1
//        [self.view addSubview:_viewProgress];
//        [self.view bringSubviewToFront:_viewProgress];
#else
        // [self.ib_lableStage setText:@"No BLE device found!"];
        [self.ib_RefreshBLE setEnabled:NO];
        [self.ib_Indicator setHidden:NO];
#endif
        
        NSLog(@"No BLE device found! schedule next check ");
        
        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(scanCameraBLEDone)
                                       userInfo:nil
                                        repeats:NO];
        
        //Check again
    }
    else if ([_currentBLEList count] == 1) //found 1 within first 5 sec. Grab it now.
    {
#if 1
        [self.viewProgress removeFromSuperview];
#else
        [self.ib_RefreshBLE setEnabled:YES];
        [self.ib_Indicator setHidden:YES];
        [self.ib_tableListBLE setHidden:NO];
#endif
        
         [[BLEConnectionManager getInstanceBLE].cm stopScan];
        
        //Update UI
        [self.ib_lableStage setText:@"Select a device to connect"];
        
        [self.ib_tableListBLE reloadData];
       
        //Auto connect
        {
            self.btnConnect.enabled = YES;
            self.selectedPeripheral = (CBPeripheral *)[[BLEConnectionManager getInstanceBLE].listBLEs objectAtIndex:0];
            
            [[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:_selectedPeripheral];
            
            [self createHubbleAlertView];
            
            
        }
        
        
    }
    else //More than 2 camera in  5sec
    {
#if 1
        //[self.viewProgress removeFromSuperview];
        [[BLEConnectionManager getInstanceBLE].cm stopScan];
        [self.ib_tableListBLE reloadData];
#else
        [self.ib_RefreshBLE setEnabled:YES];
        [self.ib_Indicator setHidden:YES];
                [self.ib_tableListBLE setHidden:NO]; 
        
        [[BLEConnectionManager getInstanceBLE].cm stopScan];
        
        [self.ib_lableStage setText:@"Select a device to connect."];
        [self.ib_tableListBLE reloadData];
        
#endif
    }
    
}
- (void)dismissIndicator
{
    _timeOutWaitingConnectBLE = nil;
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
    
    ////???? Do i need this
//    _timeOutWaitingConnectBLE = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(dismissIndicator) userInfo:nil repeats:NO];
#if 1
//    [self.view addSubview:_viewProgress];
//    [self.view bringSubviewToFront:_viewProgress];
#else
    [self.ib_Indicator setHidden:NO];
#endif
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
    //[inProgress release];
    //[_ib_lableStage release];
    
    [_ib_tableListBLE release];
    //[_ib_Indicator release];
    //[_ib_RefreshBLE release];
    [_btnConnect release];
    [_viewProgress release];
    [_searchAgainCell release];
    [_alertView release];
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
    
    //if (![Step_09_ViewController isWifiConnectionAvailable])
    {
        if (self.inProgress != nil)
        {
            NSLog(@"show progress 01 ");
            self.inProgress.hidden = NO;
            [self.view bringSubviewToFront:self.inProgress];
        }
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
    
#if 0
    NSString * msg =  @"Camera (ble) is disconnected abruptly, please retry adding camera again";
    
    
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
    
    
    UIAlertView *_myAlert = nil ;
    _myAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                          message:msg
                                         delegate:self
                                cancelButtonTitle:ok
                                otherButtonTitles:nil];
    
    _myAlert.tag = 1;
    _myAlert.delegate = self;
    //dialog.
#else
    
    
    
    // [self dismissIndicator];
    
    if (!_isBackPress)
    {
        //if button back don't press
        NSLog(@"BLE device is DISCONNECTED - Reconnect  ");
        NSDate * date;
        date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
        
        
        [[BLEConnectionManager getInstanceBLE] reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
    }
    else
    {
        //do nothing
    }
#endif
    
    
    
    
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1)
    {
        switch(buttonIndex) {
            case 0:
                
                [self.navigationController popToRootViewControllerAnimated:NO];
                
                break;
                
        }
        
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
        NSString *  version = [userDefaults objectForKey:@"FW_VERSION"];
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
            if ( [self sendCommandGetMacAddress:nil])
            {
                
                [self sendCommandGetVersion];
            }
        }
        
    }
    

    
    if ([stringResponse rangeOfString:GET_VERSION].location != NSNotFound)
    {
#if 1
        //[self.viewProgress removeFromSuperview];
//        if (_alertView != nil)
//        {
//            [_alertView close];
//        }
        [self customIOS7dialogButtonTouchUpInside:_alertView clickedButtonAtIndex:0];
#else
        [self.ib_Indicator setHidden:YES];
#endif
        //sucucessfull when writing version
        //diss miss statusDialog
        NSLog(@"get version successfull is %@", stringResponse);
        
        
        NSRange colonRange = [stringResponse rangeOfString:@": "];
        
        if (colonRange.location != NSNotFound)
        {
            NSString *fwVersion = [[stringResponse componentsSeparatedByString:@": "] objectAtIndex:1];
            
            if ([fwVersion isEqualToString:@"-1"])
                fwVersion = @"01_007_02";
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            
            [userDefaults setObject:fwVersion forKey:@"FW_VERSION"];
            //[userDefaults setObject:model forKey:@"MODEL"];
            [userDefaults synchronize];
        }
#if 0
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
        
        step04ViewController.cameraMac  = self.cameraMac;
        step04ViewController.cameraName = self.cameraName;
        
        [self.navigationController pushViewController:step04ViewController animated:NO];
        
        [step04ViewController release];
#else
        NSLog(@"Load step 40");
        //Load the next xib
        EditCamera_VController *step04ViewController = nil;
        
        step04ViewController = [[EditCamera_VController alloc]
                                initWithNibName:@"EditCamera_VController" bundle:nil];
        
        step04ViewController.cameraMac = self.cameraMac;
        step04ViewController.cameraName = self.cameraName;
        
        
        
        NSLog(@"Load step 41");
        [self.navigationController pushViewController:step04ViewController animated:NO];
        
        [step04ViewController release];
#endif
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else if (  [stringResponse rangeOfString:GET_UDID].location != NSNotFound)
    {
        //get_udid: 01008344334C32B0A0VFFRBSVA
        NSString *stringUDID = [stringResponse substringFromIndex:GET_UDID.length + 2];
        NSLog(@"Get UDID successfully - udid: %@", stringUDID);
        
        self.cameraMac = [stringUDID substringWithRange:NSMakeRange(6, 12)];
        NSString *cameraNameFinal = [NSString stringWithFormat:@"%@%@", DEFAULT_SSID_HD_PREFIX, [_cameraMac substringFromIndex:6]];
        self.cameraName = cameraNameFinal;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:self.cameraMac forKey:@"CameraMacSave"];
        [userDefaults setObject:stringUDID forKey:CAMERA_UDID];
        [userDefaults synchronize];
    }
}

-(void) moveToNextStep
{
    
    //First time enter, try to flush BLE buffer
#if 1
//    [self.view addSubview:_viewProgress];
//    [self.view bringSubviewToFront:_viewProgress];
#else
    [self.ib_Indicator setHidden:NO];
#endif
    //[self.ib_lableStage setText:@"Getting info from camera"];
    
    // FLUSH ---
    [BLEConnectionManager getInstanceBLE].delegate = self;
    
    if ([BLEConnectionManager getInstanceBLE].state == CONNECTED)
    {
        
        [[BLEConnectionManager getInstanceBLE].uartPeripheral  flush:20.0];
        
        NSLog(@" flush done ");
        NSDate * date;
        while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
        {

            date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
            
            [[NSRunLoop currentRunLoop] runUntilDate:date];
        }
        
        NSLog(@"Clear Udid");

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:CAMERA_UDID];
        [userDefaults synchronize];

        if ( [self sendCommandGetMacAddress:nil])
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
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
}


- (BOOL)sendCommandGetMacAddress:(NSTimer *)info
{
    NSLog(@"now, Send command get mac address");
    if ([BLEConnectionManager getInstanceBLE].state != CONNECTED)
    {
        NSLog(@"sendCommandGetMacAddress:  BLE disconnected - ");
        
        
        return FALSE;
    }
    
    
    //first get version of camera
    [BLEConnectionManager getInstanceBLE].delegate = self;
    
    
    //[[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_MAC_ADDRESS withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_UDID withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    NSDate * date;
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        
        NSLog(@"sendCommandGetMacAddress:  wait for result ");
        
        
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
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
#if 1
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
#else
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    CBPeripheral *peripheral = [_currentBLEList objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    
    return cell;
#endif
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 1
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        [self refreshCamBLE:nil];
    }
    else
    {
        self.btnConnect.enabled = YES;
        self.selectedPeripheral = (CBPeripheral *)[[BLEConnectionManager getInstanceBLE].listBLEs objectAtIndex:indexPath.row];
    }
#else
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //stop scanning
    [[BLEConnectionManager getInstanceBLE].cm stopScan];
    
    [self.ib_RefreshBLE setEnabled:NO];

    if ([BLEConnectionManager getInstanceBLE].state == CONNECTING )
    {
        NSLog(@"BLE is connecting... return.");
        return;
    }
    
    CBPeripheral *peripheralSelected =  [[BLEConnectionManager getInstanceBLE].listBLEs objectAtIndex:indexPath.row];
    [[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:peripheralSelected];
    [self.ib_Indicator setHidden:NO];
    
    [self.ib_tableListBLE setExclusiveTouch:YES];
    
    [self.ib_tableListBLE setHidden:YES];
#endif
}

@end