//
//  DisplayWifiList_VController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>

#import "DisplayWifiList_VController.h"
#import "NetworkInfoToCamera_VController.h"
#import "WifiListParser.h"
#import "PublicDefine.h"
#import "Step05Cell.h"
#import "WifiEntry.h"
#import "define.h"

#define BLE_TIMEOUT_PROCESS 1*60

@interface DisplayWifiList_VController () <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell *cellOtherNetwork;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellRefresh;
@property (nonatomic, weak) IBOutlet UIButton *btnContinue;
@property (nonatomic, weak) IBOutlet UITableView *mTableView;
@property (nonatomic, weak) IBOutlet UIView *viewProgress;
@property (nonatomic, weak) IBOutlet UIView *viewError;

@property (nonatomic, strong) WifiEntry *selectedWifiEntry;
@property (nonatomic, strong) NSTimer *timerTimeoutConnectBLE;
@property (nonatomic) BOOL newCmdFlag;
@property (nonatomic) BOOL shouldTimeoutProcessing;
@property (nonatomic) BOOL isAlreadyWifiList;

@end

@implementation DisplayWifiList_VController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [_btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    _btnContinue.enabled = NO;
    
    self.newCmdFlag = YES;
    
    [BLEConnectionManager.instanceBLE setDelegate:self];
    _listOfWifi = [[NSMutableArray alloc] init];
    
    UIImageView *imageView = (UIImageView *)[_viewProgress viewWithTag:585];
    imageView.animationImages = @[[UIImage imageNamed:@"loader_a"],
                                  [UIImage imageNamed:@"loader_b"],
                                  [UIImage imageNamed:@"loader_c"],
                                  [UIImage imageNamed:@"loader_d"],
                                  [UIImage imageNamed:@"loader_e"],
                                  [UIImage imageNamed:@"loader_f"]];
    imageView.animationRepeatCount = 0;
    imageView.animationDuration = 1.5f;
    [imageView startAnimating];
    
    [self showIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.shouldTimeoutProcessing = NO;
    
    //delay .1s to display new screen
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(queryWifiList) userInfo:nil repeats:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.viewError.frame = rect;
        self.viewProgress.frame = rect;
    }
    
    if ( _timerTimeoutConnectBLE) {
        [self.timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    self.timerTimeoutConnectBLE = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                                   target:self
                                                                 selector:@selector(timeoutBLESetupProcessing:)
                                                                 userInfo:nil
                                                                  repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear of DisplayWifiList_VController");
    
    if ( _timerTimeoutConnectBLE ) {
        [self.timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    [self hideIndicator];
    
    //remove delegate
    [BLEConnectionManager.instanceBLE setDelegate:nil];
}

#pragma mark - Actions

- (IBAction)btnContinueTouchUpInsideAction:(id)sender
{
    /*
     * Stopped setup proccess if selected wifi is open. DO NOT support anymore!
     * The selected is HOME or not doesn't mater, just check to confirm.
     */
    if ([_selectedWifiEntry.authMode isEqualToString:@"open"]) {
        [[[UIAlertView alloc] initWithTitle:@"SSID without password is not supported due to security concern. Please add password to your router."
                                     message:nil
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil] show];
    }
    else {
        NSRange noQoute = NSMakeRange(1, _selectedWifiEntry.ssidWithQuotes.length - 2);
        NSString *wifiName = [_selectedWifiEntry.ssidWithQuotes substringWithRange:noQoute];
        NSString *homeWifi = [[NSUserDefaults standardUserDefaults] stringForKey:HOME_SSID];
        
        if ([wifiName isEqualToString:homeWifi]) {
            [self moveToNextStep];
        }
        else {
            [self showDialogToConfirm:homeWifi selectedWifi:wifiName];
        }
    }
}

- (IBAction)btnRetryTouchUpInsideAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Methods

- (void)hubbleItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshWifiList
{
    //hide button back of navigation controller
    self.navigationItem.leftBarButtonItem.enabled = NO;
    _btnContinue.enabled = NO;
    self.isAlreadyWifiList = NO;
    self.shouldTimeoutProcessing = NO;
    
    //clear list wifi
    [_listOfWifi removeAllObjects];
    [self showIndicator];
    
    [BLEConnectionManager.instanceBLE setDelegate:self];
    [self queryWifiList];
    
    if ( _timerTimeoutConnectBLE ) {
        [_timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    self.timerTimeoutConnectBLE = [NSTimer scheduledTimerWithTimeInterval:BLE_TIMEOUT_PROCESS
                                                                   target:self
                                                                 selector:@selector(timeoutBLESetupProcessing:)
                                                                 userInfo:nil
                                                                  repeats:NO];
}

- (void)addOtherWifi
{
    WifiEntry * other = [[WifiEntry alloc]initWithSSID:@"\"Other Network\""];
    other.bssid = @"Other";
    other.authMode = @"None";
    other.signalLevel = 0;
    other.noiseLevel = 0;
    other.quality = nil;
    other.encryptType = @"None";
    
    [_listOfWifi addObject:other];
    [self filterCameraList];
}

- (void)moveToNextStep
{
    NSLog(@"Load step 6: Input network info");
    
    //Load the next xib
    NetworkInfoToCamera_VController *netWorkInfoViewController = [[NetworkInfoToCamera_VController alloc] initWithNibName:@"NetworkInfoToCamera_VController" bundle:nil];
    
    NSRange noQoutes = NSMakeRange(1, _selectedWifiEntry.ssidWithQuotes.length - 2);
    NSString *wifiName = [_selectedWifiEntry.ssidWithQuotes substringWithRange:noQoutes];
    
    [[NSUserDefaults standardUserDefaults] setObject:wifiName forKey:HOST_SSID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    netWorkInfoViewController.isOtherNetwork = [wifiName isEqualToString:@"Other Network"];
    netWorkInfoViewController.ssid = wifiName;
    netWorkInfoViewController.security = _selectedWifiEntry.authMode;
    
    [self.navigationController pushViewController:netWorkInfoViewController animated:NO];
}

- (void)showDialogToConfirm: (NSString *)homeWifi selectedWifi: (NSString *)selectedWifi
{
    NSString *msg = [NSString stringWithFormat:@"You have selected wifi %@ which is not the same as your Home wifi, %@. If you choose to continue, there will more steps to setup your camera. Do you want to proceed?", selectedWifi, homeWifi];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];
    alertView.tag = 555;
    [alertView show];
}

- (void)timeoutBLESetupProcessing:(NSTimer *)timer
{
    self.shouldTimeoutProcessing = YES;
    
    [BLEConnectionManager.instanceBLE.uartPeripheral didDisconnect];
    [BLEConnectionManager.instanceBLE setDelegate:nil];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                              Selector:@selector(removeCamSuccessWithResponse:)
                                                                          FailSelector:@selector(removeCamFailedWithError:)
                                                                             ServerErr:@selector(removeCamFailedServerUnreachable)];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *stringUDID = [userDefaults stringForKey:CAMERA_UDID];
    NSString *apiKey     = [userDefaults objectForKey:@"PortalApiKey"];
    
    DLog(@"DisplayWifiListVC - timeoutBLESetupProcessing - try to remove camera");
    
    [jsonComm deleteDeviceBlockedWithRegistrationId:stringUDID andApiKey:apiKey];
    
    [_viewProgress removeFromSuperview];
    [self.view addSubview:_viewError];
    [self.view bringSubviewToFront:_viewError];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{
    if (alertView.tag == ALERT_ASK_FOR_RETRY_WIFI_TAG) {
        switch(buttonIndex) {
            case 0:
            {
                //TODO: Go back to camera detection screen
                break;
            }
            case 1:
            {
                NSLog(@"OK button pressed");
                //retry ..
                [self queryWifiList];
                break;
            }
        }
    }
    else if (alertView.tag == RETRY_CONNECTION_BLE_FAIL_TAG) {
        if (_timerTimeoutConnectBLE) {
            [_timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else if (alertView.tag == 555) {
        if (buttonIndex == 1) {
            // Continue
            [self moveToNextStep];
        }
    }
}

- (void)filterCameraList
{
    NSMutableArray *wifiList = [@[] mutableCopy];
    for (int i = 0; i < _listOfWifi.count; i++) {
        WifiEntry *wifi = _listOfWifi[i];
        if (![wifi.ssidWithQuotes hasPrefix:@"\"Camera-"]
            &&![wifi.ssidWithQuotes isEqualToString:@"\"\""]
            && ![wifi.ssidWithQuotes hasPrefix:@"\"CameraHD-"])
        {
            [wifiList addObject:wifi];
        }
    }
    
    self.listOfWifi = wifiList;
}

#pragma mark - Table view delegates & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 1;
    }
    return _listOfWifi.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 1
    if (indexPath.section == 0) {
        if (indexPath.row < _listOfWifi.count - 1) {
            static NSString *CellIdentifier = @"Step05Cell";
            Step05Cell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Step05Cell" owner:nil options:nil];
            for (id curObj in objects) {
                if ([curObj isKindOfClass:[Step05Cell class]]) {
                    cell = (Step05Cell *)curObj;
                    break;
                }
            }
            
            WifiEntry *entry = [_listOfWifi objectAtIndex:indexPath.row];
            cell.lblName.text = [entry.ssidWithQuotes substringWithRange:NSMakeRange(1, entry.ssidWithQuotes.length - 2)]; // Remove " & "
            
            return cell;
        }
        else {
            return _cellOtherNetwork;
        }
    }
    else {
        return _cellRefresh;
    }
#else
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    WifiEntry *entry = [_listOfWifi objectAtIndex:indexPath.row];
    cell.textLabel.text = entry.ssid_w_quote;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
#endif
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        self.btnContinue.enabled = YES;
        self.selectedWifiEntry = (WifiEntry *)[_listOfWifi objectAtIndex:indexPath.row];
    }
    else {
        [self refreshWifiList];
    }
}

#pragma mark -

- (void)showIndicator
{
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
}

- (void)hideIndicator
{
    //[self.ib_Indicator setHidden:YES];
    [_viewProgress removeFromSuperview];
}

- (void)askForRetry
{
    //    [[BLEConnectionManager getInstanceBLE] disconnect];
    UIAlertView *_myAlert = [[UIAlertView alloc] initWithTitle:LocStr(@"Fail_to_communicate_with_camera")
                                                       message:@""
                                                      delegate:self
                                             cancelButtonTitle:LocStr(@"Cancel")
                                             otherButtonTitles:LocStr(@"Retry"), nil];
    
    _myAlert.tag = ALERT_ASK_FOR_RETRY_WIFI_TAG;
    _myAlert.delegate = self;
    
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [_myAlert setTransform:myTransform];
    [_myAlert show];
}

- (void)queryWifiList
{
    //delay send command to camera BLE 1s.
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendCommandGetWifiList) userInfo:nil repeats:NO];
}

- (void)sendCommandGetWifiList
{
    // check state BLE
    if ( BLEConnectionManager.instanceBLE.state != CONNECTED ) {
        NSLog(@"BLE disconnected, can't sendCommandGetWifiList!!!!");
        return;
    }
    
    // retry sending get wifi
    NSLog(@"Send command get routers list, now!!!");
    [BLEConnectionManager.instanceBLE setDelegate:self];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION]; // 01.12.58
    
    if ([fwVersion compare:FW_MILESTONE] >= NSOrderedSame) {
        // fw >= FW_MILESTONE
        self.newCmdFlag = YES;
        [BLEConnectionManager.instanceBLE.uartPeripheral writeString:GET_ROUTER_LIST2
                                                         withTimeOut:LONG_TIME_OUT_SEND_COMMAND];
    }
    else {
        self.newCmdFlag = NO;
        [BLEConnectionManager.instanceBLE.uartPeripheral writeString:GET_ROUTER_LIST
                                                         withTimeOut:LONG_TIME_OUT_SEND_COMMAND];
    }
    
    NSDate *date;
    while ( BLEConnectionManager.instanceBLE.uartPeripheral.isBusy ) {
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }    
}

- (void)dialogFailConnection:(NSTimer *)timer
{
    if ( BLEConnectionManager.instanceBLE.state == CONNECTED ) {
        //Check after TIME_OUT_RECONNECT_BLE seconds, if connected retrun
        return;
    }
    
    //show info
    NSString *msg =  @"Camera (ble) is disconnected abruptly, please retry adding camera again";
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:msg
                                                     delegate:self
                                            cancelButtonTitle:LocStr(@"Ok")
                                            otherButtonTitles:nil];
    
    myAlert.tag = RETRY_CONNECTION_BLE_FAIL_TAG;
    myAlert.delegate = self;
}

#pragma mark - BLEConnectionManagerDelegate

- (void)didReceiveData:(NSString *)string
{
    NSLog(@"Data Receiving router list is %@", string);
    //processing data receive wifi list
    
    if ( string.length > 0 ) {
        NSData *router_list_raw = [string dataUsingEncoding:NSUTF8StringEncoding];
        if ( router_list_raw ) {
            WifiListParser * routerListParser = nil;
            routerListParser = [[WifiListParser alloc] initWithNewCmdFlag:_newCmdFlag];
            
            [routerListParser parseData:router_list_raw
                           whenDoneCall:@selector(setWifiResult:)
                          whenErrorCall:@selector(errorCallback:)
                                 target:self];
        }
        else {
            NSLog(@"GOT NULL wifi list from camera");
            [self queryWifiList];
        }
    }
    else {
        //string received is nil
        [self queryWifiList];
    }
}

- (void)reconnectBLE
{
    NSDate *date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    [BLEConnectionManager.instanceBLE setDelegate:self];
    [BLEConnectionManager.instanceBLE reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
}

- (void)bleDisconnected
{
    if (_shouldTimeoutProcessing) {
        NSLog(@"Timeout - BLE process takes too long time");
    }
    else {
        NSLog(@"BLE device is DISCONNECTED - Reconnect after 2s ");
        [self reconnectBLE];
    }
}

- (void)didConnectToBle:(CBUUID *)service_id
{
    NSLog(@"BLE device connected again(DisplayWifiList_VController) -isAlreadyWifiList: %d", _isAlreadyWifiList);
    if (!_isAlreadyWifiList) {
        [self queryWifiList];
    }
}

- (void)errorCallback:(NSError *)error
{
    NSLog(@"error return is %@", error);
    [self queryWifiList];
}

- (void)setWifiResult:(NSArray *)wifiList
{
    //show back button
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    if (_timerTimeoutConnectBLE) {
        [_timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    NSLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count);
    self.listOfWifi = [NSMutableArray arrayWithArray:wifiList];
    [self addOtherWifi];
    WifiEntry * entry;
    NSLog(@"List wifi after refreshing is:");
    for (int i =0; i< wifiList.count; i++) {
        entry = [wifiList objectAtIndex:i];
        NSLog(@"entry: %d, ssid_w_quote: %@, bssid: %@, auth_mode: %@, quality: %@", i, entry.ssidWithQuotes, entry.bssid, entry.authMode, entry.quality);
    }
    
    self.isAlreadyWifiList = YES;
    
    //filter Camera list
    [self filterCameraList];
    [_mTableView reloadData];
    [self hideIndicator];
}

- (void)showDialog:(NSTimer *)timer
{
    [self askForRetry];
}

#pragma mark - JSON_Comm call back

- (void)removeCamSuccessWithResponse:(NSDictionary *)responseData
{
	NSLog(@"removeCam success");
}

- (void)removeCamFailedWithError:(NSDictionary *)error_response
{
	NSLog(@"removeCam failed Server error: %@", [error_response objectForKey:@"message"]);
}

- (void)removeCamFailedServerUnreachable
{
	NSLog(@"server unreachable");
}

@end
