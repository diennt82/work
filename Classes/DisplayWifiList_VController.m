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

@interface DisplayWifiList_VController () <UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableViewCell *cellOtherNetwork;
@property (nonatomic, strong) IBOutlet UITableViewCell *cellRefresh;
@property (nonatomic, strong) IBOutlet UIView *viewProgress;
@property (nonatomic, strong) IBOutlet UIView *viewError;
@property (nonatomic, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *selectWifiLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectYourOwnNetworkLabel;
@property (weak, nonatomic) IBOutlet UILabel *mustBePasswordProtectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *detectedWifiNetworkLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherNetworkLabel;
@property (weak, nonatomic) IBOutlet UILabel *refreshLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchingForWifiNetworksLabel;
@property (weak, nonatomic) IBOutlet UILabel *pleaseWaitLabel;
@property (weak, nonatomic) IBOutlet UILabel *unableToDetectCameraLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeoutLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;


@property (nonatomic, strong) WifiEntry *selectedWifiEntry;
@property (nonatomic, strong) NSTimer *timerTimeoutConnectBLE;
@property (nonatomic) BOOL newCmdFlag;
@property (nonatomic) BOOL shouldTimeoutProcessing;
@property (nonatomic) BOOL isAlreadyWifiList;

@end

@implementation DisplayWifiList_VController

#define BLE_TIMEOUT_PROCESS 1*60
#define WIFI_IS_NOT_HOME_WIFI_TAG 555

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _selectWifiLabel.text = LocStr(@"Select a Wi-Fi network to connect camera to");
    _selectYourOwnNetworkLabel.text = LocStr(@"Select your own trusted network.");
    _mustBePasswordProtectedLabel.text = LocStr(@"(It must be password protected)");
    _detectedWifiNetworkLabel.text = LocStr(@"Detected Wi-Fi network");
    [_continueButton setTitle:LocStr(@"Continue") forState:UIControlStateNormal];
    _otherNetworkLabel.text = LocStr(@"Other network");
    _refreshLabel.text = LocStr(@"Refresh");
    _searchingForWifiNetworksLabel.text = LocStr(@"Searching for Wi-Fi networks");
    _pleaseWaitLabel.text = LocStr(@"Please wait");
    _unableToDetectCameraLabel.text = LocStr(@"Unable to detect camera");
    _timeoutLabel.text = LocStr(@"Timeout");
    [_retryButton setTitle:LocStr(@"Retry") forState:UIControlStateNormal];
    
    [_continueButton setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_continueButton setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    _continueButton.enabled = NO;
    
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
    
    // delay .1s to display new screen
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
    DLog(@"viewWillDisappear of DisplayWifiList_VController");
    
    if ( _timerTimeoutConnectBLE ) {
        [self.timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    [self hideIndicator];
    
    // remove delegate
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
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil
                                                            message:LocStr(@"Using an SSID without a password is not supported due to security concerns. Setup a password on your router.")
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:LocStr(@"Ok"), nil];
        [alertview show];
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

- (void)refreshWifiList
{
    //hide button back of navigation controller
    self.navigationItem.leftBarButtonItem.enabled = NO;
    _continueButton.enabled = NO;
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
    NSString *msg = LocStr(@"You have selected wifi %@ which is not the same as your Home wifi, %@. If you choose to continue, there will more steps to setup your camera. Do you want to proceed?");
    msg = [NSString stringWithFormat:msg, selectedWifi, homeWifi];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:LocStr(@"Cancel")
                                              otherButtonTitles:LocStr(@"Continue"), nil];
    alertView.tag = WIFI_IS_NOT_HOME_WIFI_TAG;
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
    if ( buttonIndex == alertView.cancelButtonIndex ) {
        return;
    }
    
    if (alertView.tag == ALERT_ASK_FOR_RETRY_WIFI_TAG) {
        // Retry ..
        DLog(@"OK button pressed");
        [self queryWifiList];
    }
    else if (alertView.tag == RETRY_CONNECTION_BLE_FAIL_TAG) {
        if (_timerTimeoutConnectBLE) {
            [_timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else if (alertView.tag == WIFI_IS_NOT_HOME_WIFI_TAG) {
        // Continue
        [self moveToNextStep];
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
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        self.continueButton.enabled = YES;
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
    [_viewProgress removeFromSuperview];
}

- (void)askForRetry
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:LocStr(@"Failed to communicate with camera. Retry?")
                                                   delegate:self
                                          cancelButtonTitle:LocStr(@"Cancel")
                                          otherButtonTitles:LocStr(@"Retry"), nil];
    
    alert.tag = ALERT_ASK_FOR_RETRY_WIFI_TAG;
    
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [alert setTransform:myTransform];
    [alert show];
}

- (void)queryWifiList
{
    // delay send command to camera BLE 1s.
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendCommandGetWifiList) userInfo:nil repeats:NO];
}

- (void)sendCommandGetWifiList
{
    // check state BLE
    if ( BLEConnectionManager.instanceBLE.state != CONNECTED ) {
        DLog(@"BLE disconnected, can't sendCommandGetWifiList!!!!");
        return;
    }
    
    // retry sending get wifi
    DLog(@"Send command get routers list, now!!!");
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
        // Check after TIME_OUT_RECONNECT_BLE seconds, if connected return
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocStr(@"Error")
                                                        message:LocStr(@"Camera (BLE) disconnected abruptly, please retry adding camera.")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:LocStr(@"Ok"), nil];
    
    alertView.tag = RETRY_CONNECTION_BLE_FAIL_TAG;
    [alertView show];
}

#pragma mark - BLEConnectionManagerDelegate

- (void)didReceiveData:(NSString *)string
{
    DLog(@"Data Receiving router list is %@", string);
    if ( string.length > 0 ) {
        NSData *routerListRaw = [string dataUsingEncoding:NSUTF8StringEncoding];
        if ( routerListRaw ) {
            WifiListParser * routerListParser = nil;
            routerListParser = [[WifiListParser alloc] initWithNewCmdFlag:_newCmdFlag];
            
            [routerListParser parseData:routerListRaw
                           whenDoneCall:@selector(setWifiResult:)
                          whenErrorCall:@selector(errorCallback:)
                                 target:self];
        }
        else {
            DLog(@"GOT NULL wifi list from camera");
            [self queryWifiList];
        }
    }
    else {
        // string received is nil
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
        DLog(@"Timeout - BLE process takes too long time");
    }
    else {
        DLog(@"BLE device is DISCONNECTED - Reconnect after 2s ");
        [self reconnectBLE];
    }
}

- (void)didConnectToBle:(CBUUID *)serviceId
{
    DLog(@"BLE device connected again(DisplayWifiList_VController) -isAlreadyWifiList: %d", _isAlreadyWifiList);
    if (!_isAlreadyWifiList) {
        [self queryWifiList];
    }
}

- (void)errorCallback:(NSError *)error
{
    DLog(@"error return is %@", error);
    [self queryWifiList];
}

- (void)setWifiResult:(NSArray *)wifiList
{
    // enable back button
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    if (_timerTimeoutConnectBLE) {
        [_timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    DLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count);
    self.listOfWifi = [NSMutableArray arrayWithArray:wifiList];
    [self addOtherWifi];
    
    DLog(@"List wifi after refreshing is:");
    WifiEntry *entry;
    for (int i =0; i< wifiList.count; i++) {
        entry = wifiList[i];
        DLog(@"entry: %d, ssid_w_quote: %@, bssid: %@, auth_mode: %@, quality: %@", i, entry.ssidWithQuotes, entry.bssid, entry.authMode, entry.quality);
    }
    
    self.isAlreadyWifiList = YES;
    
    // filter Camera list
    [self filterCameraList];
    [_tableView reloadData];
    [self hideIndicator];
}

- (void)showDialog:(NSTimer *)timer
{
    [self askForRetry];
}

#pragma mark - JSON_Comm call back

- (void)removeCamSuccessWithResponse:(NSDictionary *)responseData
{
	DLog(@"removeCam success");
}

- (void)removeCamFailedWithError:(NSDictionary *)errorResponse
{
	DLog(@"removeCam failed Server error: %@", errorResponse[@"message"]);
}

- (void)removeCamFailedServerUnreachable
{
	DLog(@"server unreachable");
}

@end
