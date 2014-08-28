//
//  CreateBLEConnection_VController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "CreateBLEConnection_VController.h"
#import "MBP_iosViewController.h"
#import "EditCamera_VController.h"
#import "Step_10_ViewController.h"
#import "BLEConnectionCell.h"
#import "CustomIOS7AlertView.h"
#import "PublicDefine.h"

@interface CreateBLEConnection_VController () <CustomIOS7AlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;
@property (nonatomic, weak) IBOutlet UILabel *selectCameraLabel;
@property (nonatomic, weak) IBOutlet UILabel *detectingCameraLabel;
@property (nonatomic, weak) IBOutlet UILabel *instructionLabel;
@property (nonatomic, weak) IBOutlet UILabel *mayTakeAMinuteLabel;
@property (nonatomic, weak) IBOutlet UILabel *detectingViaBluetoothLabel;
@property (nonatomic, weak) IBOutlet UILabel *mayTakeAMinuteLabel2;
@property (nonatomic, weak) IBOutlet UILabel *unableToDetectCameraLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeoutLabel;
@property (nonatomic, weak) IBOutlet UIButton *retryButton;
@property (nonatomic, weak) IBOutlet UILabel *searchAgainLabel;

@property (nonatomic, strong) IBOutlet UIView *viewProgress;
@property (nonatomic, strong) IBOutlet UIView *viewError;
@property (nonatomic, strong) IBOutlet UIView *viewPairNDetecting;
@property (nonatomic, strong) IBOutlet UITableViewCell *searchAgainCell;

@property (nonatomic, strong) UIView *searchingView;

@property (nonatomic, strong) CBPeripheral *selectedPeripheral;
@property (nonatomic, strong) CustomIOS7AlertView *alertView;

@property (nonatomic, strong) NSTimer *timerTimeoutConnectBLE;
@property (nonatomic, strong) NSTimer *timerScanCameraBLEDone;
@property (nonatomic, strong) NSTimer *macAddressTimer;

@property (nonatomic) BOOL shouldTimeoutProcessing;
@property (nonatomic) BOOL rescanFlag;
@property (nonatomic) BOOL isNotFirstTime;

@property (nonatomic) BOOL isBackPress;
@property (nonatomic) BOOL taskCancelled;
@property (nonatomic) BOOL showProgressNextTime;

@end

@implementation CreateBLEConnection_VController

#define RETRY_BUTTON_TAG        599
#define SEARCHING_VIEW_TAG      675
#define SETUP_CAMERA_IMAGE_TAG  575

#define BLE_TIMEOUT_PROCESS 1*60

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showProgressNextTime= NO;
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"logo"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [_connectButton setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_connectButton setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    _connectButton.enabled = NO;
    
    [_retryButton setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_retryButton setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    [_retryButton addTarget:self action:@selector(retryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentBLEList = [[NSMutableArray alloc] init];
    
    _selectCameraLabel.text = LocStr(@"Select camera");
    _detectingCameraLabel.text = LocStr(@"Detecting the camera");
    _instructionLabel.text = LocStr(@"Press and hold the button marked 'PAIR' for 3 seconds");
    _mayTakeAMinuteLabel.text = LocStr(@"This may take up to a minute");
    _detectingViaBluetoothLabel.text = LocStr(@"Detecting camera via Bluetooth");
    _mayTakeAMinuteLabel2.text = LocStr(@"This may take up to a minute");
    _unableToDetectCameraLabel.text = LocStr(@"Unable to detect camera");
    _timeoutLabel.text = LocStr(@"Timeout");
    _searchAgainLabel.text = LocStr(@"Search again");
    [_connectButton setTitle:LocStr(@"Connect") forState:UIControlStateNormal];
    [_retryButton setTitle:LocStr(@"Retry") forState:UIControlStateNormal];
    
    UIImageView *imageView  = (UIImageView *)[_viewProgress viewWithTag:SETUP_CAMERA_IMAGE_TAG];
    imageView.animationImages = @[[UIImage imageNamed:@"setup_camera_c1"],
                                  [UIImage imageNamed:@"setup_camera_c2"],
                                  [UIImage imageNamed:@"setup_camera_c3"],
                                  [UIImage imageNamed:@"setup_camera_c4"]];
    imageView.animationDuration = 1.5f;
    imageView.animationRepeatCount = 0;

    self.searchingView = (UIView *)[self.viewPairNDetecting viewWithTag:SEARCHING_VIEW_TAG];
    
    UIImageView *imgView  = (UIImageView *)[_searchingView viewWithTag:SETUP_CAMERA_IMAGE_TAG];
    imgView.animationImages = @[[UIImage imageNamed:@"setup_camera_c1"],
                                  [UIImage imageNamed:@"setup_camera_c2"],
                                  [UIImage imageNamed:@"setup_camera_c3"],
                                  [UIImage imageNamed:@"setup_camera_c4"]];
    imgView.animationDuration = 1.5f;
    imgView.animationRepeatCount = 0;
    
    [self.view addSubview:_viewPairNDetecting];
    [self.view bringSubviewToFront:_viewPairNDetecting];
    
    [imgView startAnimating];
    [imageView startAnimating];
    
    self.homeWifiSSID = [CameraPassword fetchSSIDInfo];
    DLog(@"homeWifiSSID: %@", self.homeWifiSSID);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_homeWifiSSID forKey:HOME_SSID];
    [userDefaults synchronize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _viewError.frame = rect;
        _viewProgress.frame = rect;
    }
    
    [self createBLEConnectionRescan:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *viewControllers = self.navigationController.viewControllers;
	if ([viewControllers indexOfObject:self] == NSNotFound) {
		// View is disappearing because it was popped from the stack
		DLog(@"View controller was popped --- We are closing down..task_cancelled = YES");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
    
    self.taskCancelled = YES;
    
    // remove delegate
    BLEConnectionManager.instanceBLE.delegate = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Actions

- (IBAction)btnConnectTouchUpInsideAction:(id)sender
{
    [BLEConnectionManager.instanceBLE.cm stopScan];
    
    if ( BLEConnectionManager.instanceBLE.state == CONNECTING ) {
        DLog(@"BLE is connecting... return.");
        return;
    }
    
    DLog(@"CreateBLE VC - btnConnectTouchUpInsideAction: %@", _selectedPeripheral);
    [BLEConnectionManager.instanceBLE connectToBLEWithPeripheral:_selectedPeripheral];
    
    [self createHubbleAlertView];
}

- (void)retryButtonAction
{
    DLog(@"CreateBLE VC - retryButtonAction - refreshCamBLE");
    [_viewError removeFromSuperview];
    self.shouldTimeoutProcessing = NO;
    [self createBLEConnectionRescan:_rescanFlag];
}

- (void)hubbleItemAction:(id)sender
{
    self.isBackPress = YES;
    ConnectionState stateConnectBLE = BLEConnectionManager.instanceBLE.state;
    DLog(@"CreateBLE VC - hubbleItemAction - stateConnectBLE: %d", stateConnectBLE);
    if ( stateConnectBLE != CONNECTED ) {
        // in state : SCANNING OR IDLE
        self.isBackPress = NO;
        [[BLEConnectionManager.instanceBLE uartPeripheral] didDisconnect];
        
        self.shouldTimeoutProcessing = YES;
        
        if (_timerScanCameraBLEDone) {
            [_timerScanCameraBLEDone invalidate];
            self.timerScanCameraBLEDone = nil;
        }
        
        if (_timerTimeoutConnectBLE) {
            [_timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        [BLEConnectionManager.instanceBLE stopScanBLE];
        BLEConnectionManager.instanceBLE.delegate = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        // In State CONNECTED
        // wait for return from delegate, handle it on bleDisconnected disconnect to BLE
        BLEConnectionManager.instanceBLE.delegate = nil;
        [BLEConnectionManager.instanceBLE disconnect];
    }
}

- (void)refreshCamBLE
{
    [self createBLEConnectionRescan:YES];
}

- (void)timeoutBLESetupProcessing:(NSTimer *)timer
{
    self.shouldTimeoutProcessing = YES;
    
    if (_timerScanCameraBLEDone) {
        [_timerScanCameraBLEDone invalidate];
        self.timerScanCameraBLEDone = nil;
    }
    
    [_viewProgress removeFromSuperview];
    [_viewPairNDetecting removeFromSuperview];
    [self customIOS7dialogButtonTouchUpInside:_alertView clickedButtonAtIndex:0];
    
    [self.view addSubview:_viewError];
    [self.view bringSubviewToFront:_viewError];
}

#pragma mark - Hubble alert view & delegate

- (void)createHubbleAlertView
{
    // Here we need to pass a full frame
    if ( !_alertView ) {
        self.alertView = [[CustomIOS7AlertView alloc] init];
        // Add some custom content to the alert view
        [_alertView setContainerView:[self createDemoView]];
        
        // Modify the parameters
        [_alertView setButtonTitles:nil];
        [_alertView setDelegate:self];
        
        // You may use a Block, rather than a delegate.
        [_alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            DLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
            [alertView close];
        }];
        
        [_alertView setUseMotionEffects:YES];
    }

    // And launch the dialog
    [_alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside:(CustomIOS7AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, alertView.tag);
    [alertView close];
}

- (UIView *)createDemoView
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 140)];
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 200, 21)];// autorelease];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = LocStr(@"Connecting to camera");
    [demoView addSubview:label];
    
    return demoView;
}

#pragma mark - Methods

- (void)createBLEConnectionRescan:(BOOL)rescanFlag
{
    DLog(@"CreateBLE VC - createBLEConnectionRescan: %d", rescanFlag);
    
    if (rescanFlag) {
        [self.view addSubview:_viewProgress];
        [self.view bringSubviewToFront:_viewProgress];
    }
    else {
        [self.view addSubview:_viewPairNDetecting];
        [self.view bringSubviewToFront:_viewPairNDetecting];
    }
    
    [self clearDataBLEConnection];
    
    if (_currentBLEList) {
        [_currentBLEList removeAllObjects];
    }
    
    [self.tableView reloadData];

    self.taskCancelled = NO;
    
    BLEConnectionManager.instanceBLE.delegate = self;
    BLEConnectionManager.instanceBLE.needReconnect = YES;
    
    if (rescanFlag) {
        [BLEConnectionManager.instanceBLE reScan];
    }
    else {
        [BLEConnectionManager.instanceBLE scan];
    }
    
    if (_timerScanCameraBLEDone) {
        [_timerScanCameraBLEDone invalidate];
        self.timerScanCameraBLEDone = nil;
    }
    
    self.timerScanCameraBLEDone = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scanCameraBLEDone) userInfo:nil repeats:NO];
    
    if ( _timerTimeoutConnectBLE  ) {
        [_timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    self.timerTimeoutConnectBLE = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                                   target:self
                                                                 selector:@selector(timeoutBLESetupProcessing:)
                                                                 userInfo:nil
                                                                  repeats:NO];
}

- (void)scanCameraBLEDone
{
    DLog(@"CreateBLEConnection_VC - scanCameraBLEDone - task_cancelled: %d, - _currentBLEList count: %d, - shouldTimeoutProcessing: %d", _taskCancelled, _currentBLEList.count, _shouldTimeoutProcessing);
    
    if ( _taskCancelled ) {
        return;
    }
    
    _searchingView.hidden = NO;
    
    if ( _currentBLEList.count == 0) {
        // No camera found
        DLog(@"No BLE device found! schedule next check ");
        
        // Check again
        self.timerScanCameraBLEDone = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                       target:self
                                                                     selector:@selector(scanCameraBLEDone)
                                                                     userInfo:nil
                                                                      repeats:NO];
    }
    else {
        // NOTE: The list is filtered while scanning, only known devices are shown here
        self.rescanFlag = YES;
        
        [BLEConnectionManager.instanceBLE.cm stopScan];
        
        if ( _currentBLEList.count == 1 ) {
            // connect directly
            [_viewProgress removeFromSuperview];
            [_viewPairNDetecting removeFromSuperview];
            [_tableView reloadData];
            
            _connectButton.enabled = YES;
            self.selectedPeripheral = (CBPeripheral *)[_currentBLEList firstObject];
            DLog(@"Found 1 %@, connect now", _selectedPeripheral.name);
            
            [BLEConnectionManager.instanceBLE connectToBLEWithPeripheral:_selectedPeripheral];
            
            [self createHubbleAlertView];
        }
        else {
            // Equal or more than 2
            DLog(@"Found more than 1 valid devices -> Show lists");
            
            [_viewProgress removeFromSuperview];
            [_viewPairNDetecting removeFromSuperview];
            [_tableView reloadData];
            _connectButton.enabled = YES;
        }
    }
}

- (void)dismissIndicator
{
    if (_timerTimeoutConnectBLE) {
        [_timerTimeoutConnectBLE invalidate];
        [self setTimerTimeoutConnectBLE:nil];
    }
}

// This is called when BLE is connected & RX, TX characteristic is found
- (void)updateUIConnection:(NSTimer *)info
{
    if (BLEConnectionManager.instanceBLE.state == CONNECTED) {
        // Start sending commands now
        [self moveToNextStep];
    }
    else {
        DLog(@"updateUIConnection : BLE state is %d, not CONNECTED", BLEConnectionManager.instanceBLE.state);
    }
}

#pragma mark -

- (void)handleEnteredBackground
{
    self.showProgressNextTime = YES;
}

- (void)becomeActive
{
    self.taskCancelled = NO;
}

#pragma mark - BLEConnectionManagerDelegate

- (void)bleDisconnected
{
    DLog(@"CreateBLEConnection_VC - bleDisconnected - _isBackPress: %d, -shouldTimeout: %d", _isBackPress, _shouldTimeoutProcessing);
    
    if (!_isBackPress) {
        if (_shouldTimeoutProcessing) {
            DLog(@"CreateBLEConnection_VC - bleDisconnected - Timeout, popup the error view");
        }
        else {
            //if button back don't press
            DLog(@"BLE device is DISCONNECTED - Reconnect  ");
            NSDate *date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
            [[NSRunLoop currentRunLoop] runUntilDate:date];
            
            [BLEConnectionManager.instanceBLE reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
        }
    }
    else {
        //do nothing
        if ( _timerTimeoutConnectBLE ) {
            [_timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }

        DLog(@"CreateBLEConnection_VC - bleDisconnected - _isBackPress = TRUE");
    }
}

- (void)didConnectToBle:(CBUUID *)serviceId
{
    DLog(@"BLE device connected - performSelector now");
    
    [self performSelectorOnMainThread:@selector(updateUIConnection:) withObject:nil waitUntilDone:NO];
}

- (void)onReceiveDataError:(int)errorCode forCommand:(NSString *)commandToCamera
{
    
}

- (void)didReceiveData:(NSString *)stringResponse
{
    DLog(@"Receive string %@", stringResponse);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ( !stringResponse ) {
        // check which step it is
        NSString * udid = [userDefaults objectForKey:CAMERA_UDID];
        NSString *  version = [userDefaults objectForKey:FW_VERSION];
        
        if ( udid ) {
            if ( version ) {
                DLog(@"Receive nil string from no where.");
                return;
            }
            else {
                // Retry GetVersion
                [self sendCommandGetVersion];
            }
        }
        else {
            // Retry Camera UDID & version
            if ( [self sendCommandGetUDID:nil] ) {
                
                [self sendCommandGetVersion];
            }
        }
    }
    else if ([stringResponse rangeOfString:GET_VERSION].location != NSNotFound)
    {
        [self customIOS7dialogButtonTouchUpInside:_alertView clickedButtonAtIndex:0];
        
        // sucucessful when writing version, dismiss statusDialog
        DLog(@"CreateBLEConnection_VC -get version successfull: %@", stringResponse);
        NSRange colonRange = [stringResponse rangeOfString:@": "];
        
        if (colonRange.location != NSNotFound) {
            NSString *fwVersion = [[stringResponse componentsSeparatedByString:@": "] objectAtIndex:1];
            
            if ([fwVersion isEqualToString:@"-1"]) {
                fwVersion = @"01_007_02";
            }
            
            [userDefaults setObject:fwVersion forKey:FW_VERSION];
            [userDefaults setObject:self.cameraName forKey:CAMERA_SSID];
            [userDefaults synchronize];
        }
        else {
            DLog(@"CreateBLEConnection_VC - get version NOT found");
        }
        
        EditCamera_VController *step04ViewController = [[EditCamera_VController alloc] initWithNibName:@"EditCamera_VController" bundle:nil];
        step04ViewController.cameraMac = self.cameraMac;
        step04ViewController.cameraName = self.cameraName;
        
        DLog(@"Load step 41 - EditCamera_VC");
        [self.navigationController pushViewController:step04ViewController animated:NO];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        if (_timerTimeoutConnectBLE) {
            [_timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        if (_timerScanCameraBLEDone) {
            [_timerScanCameraBLEDone invalidate];
            self.timerScanCameraBLEDone = nil;
        }
    }
    else if ( [stringResponse rangeOfString:GET_UDID].location != NSNotFound ) {
        //get_udid: 01008344334C32B0A0VFFRBSVA
        NSString *stringUDID = [stringResponse substringFromIndex:GET_UDID.length + 2];
        DLog(@"Get UDID successfully - udid: %@", stringUDID);
        
        self.cameraMac = [stringUDID substringWithRange:NSMakeRange(6, 12)];
        
        // Make sure a valid camera name.
        if ( _selectedPeripheral.name ) {
            self.cameraName = _selectedPeripheral.name;
        }
        else {
            NSString *cameraNameFinal = [NSString stringWithFormat:@"%@%@%@", DEFAULT_SSID_HD_PREFIX, [stringUDID substringWithRange:NSMakeRange(2, 4)], [_cameraMac substringFromIndex:6]];
            self.cameraName = cameraNameFinal;
        }
        
        [userDefaults setObject:_cameraMac forKey:@"CameraMacSave"];
        [userDefaults setObject:stringUDID forKey:CAMERA_UDID];
        [userDefaults synchronize];
    }
    else {
        DLog(@"CreateBLEConnectionVC - didReceiveData - Unknown error");
    }
}

- (void)moveToNextStep
{
    // First time enter, try to flush BLE buffer
    
    // FLUSH ---
    BLEConnectionManager.instanceBLE.delegate = self;
    
    if (BLEConnectionManager.instanceBLE.state == CONNECTED) {
        DLog(@"Clear UDID");
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:CAMERA_UDID];
        [userDefaults synchronize];
        
        if ( [self sendCommandGetUDID:nil] ) {
            [self sendCommandGetVersion];
        }
    }
    else {
        [self dismissIndicator];
    }
}

- (void)sendCommandGetVersion
{
    if (BLEConnectionManager.instanceBLE.state != CONNECTED) {
        return;
    }
    
    DLog(@"Now, send command get version");
    // first get mac address of camera
    BLEConnectionManager.instanceBLE.delegate = self;
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:GET_VERSION withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    
    NSDate *date;
    while (BLEConnectionManager.instanceBLE.uartPeripheral.isBusy) {
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
}

- (BOOL)sendCommandGetUDID:(NSTimer *)info
{
    DLog(@"now, Send command get udid");
    
    if (BLEConnectionManager.instanceBLE.state != CONNECTED) {
        DLog(@"sendCommandGetUDID:  BLE disconnected - ");
        return NO;
    }
    
    // first get version of camera
    BLEConnectionManager.instanceBLE.delegate = self;
    
    [BLEConnectionManager.instanceBLE.uartPeripheral writeString:GET_UDID withTimeOut:SHORT_TIME_OUT_SEND_COMMAND];
    NSDate *date;
    BOOL debugLog = YES;
    
    while (BLEConnectionManager.instanceBLE.uartPeripheral.isBusy) {
        if (debugLog) {
            DLog(@"sendCommandGetUDID:  wait for result...");
            debugLog = NO;
        }
        
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    return YES;
}

- (void)clearDataBLEConnection
{
    [BLEConnectionManager.instanceBLE.listBLEs removeAllObjects];
    [BLEConnectionManager.instanceBLE.cm stopScan];
    BLEConnectionManager.instanceBLE.state = IDLE;
}

- (void)didReceiveBLEList:(NSMutableArray *)bleLists
{
    self.currentBLEList = bleLists;
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
    
    return _currentBLEList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"BLEConnectionCell";
        BLEConnectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BLEConnectionCell" owner:nil options:nil];
        
        for (id curObj in objects) {
            if ([curObj isKindOfClass:[BLEConnectionCell class]]) {
                cell = (BLEConnectionCell *)curObj;
                break;
            }
        }
        
        CBPeripheral *peripheral = [_currentBLEList objectAtIndex:indexPath.row];
        cell.lblName.text = peripheral.name;
        
        return cell;
    }
    else {
        return _searchAgainCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self refreshCamBLE];
    }
    else {
        _connectButton.enabled = YES;
        self.selectedPeripheral = (CBPeripheral *)BLEConnectionManager.instanceBLE.listBLEs[indexPath.row];
    }
}

@end