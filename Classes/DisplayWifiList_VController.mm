//
//  DisplayWifiList_VController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "DisplayWifiList_VController.h"
#import "Step05Cell.h"
#import "define.h"
#import "WifiListParser.h"

#define BLE_TIMEOUT_PROCESS 1*60

@interface DisplayWifiList_VController () <UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell *cellOtherNetwork;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellRefresh;
@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UITableView *mTableView;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;
@property (retain, nonatomic) IBOutlet UIView *viewError;

@property (retain, nonatomic) WifiEntry *selectedWifiEntry;
@property (nonatomic) BOOL newCmdFlag;
@property (retain, nonatomic) NSTimer *timerTimeoutConnectBLE;
@property (nonatomic) BOOL shouldTimeoutProcessing;
@property (nonatomic) BOOL isAlreadyWifiList;

@end

@implementation DisplayWifiList_VController


@synthesize listOfWifi = _listOfWifi;
@synthesize cellView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void) dealloc
{
    
    [_listOfWifi release];
    //[_refreshWifiList release];
    [_ib_Indicator release];
    [_ib_LabelState release];
    [_cellOtherNetwork release];
    [_btnContinue release];
    [_mTableView release];
    [_viewProgress release];
    [_cellRefresh release];
    [_viewError release];
    [super dealloc];
}
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
    
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    self.btnContinue.enabled = NO;
    self.newCmdFlag = TRUE;
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
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

-(void) viewWillAppear:(BOOL)animated
{
    //delay .1s to display new screen
    [super viewWillAppear:animated];
    self.shouldTimeoutProcessing = FALSE;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(queryWifiList) userInfo:nil repeats:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.viewError.frame = rect;
        self.viewProgress.frame = rect;
    }
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear of DisplayWifiList_VController");
    
    if (_timerTimeoutConnectBLE)
    {
        [self.timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    [self hideIndicator];
    //remove delegate
    [BLEConnectionManager getInstanceBLE].delegate = nil;
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Actions

- (IBAction)btnContinueTouchUpInsideAction:(id)sender
{
    /*
     * Stopped setup proccess if selected wifi is open. DO NOT support anymore!
     * The selected is HOME or not doesn't mater, just check to confirm.
     */
    
    if ([_selectedWifiEntry.auth_mode isEqualToString:@"open"])
    {
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_ssid_without_password_not_supported", nil, [NSBundle mainBundle], @"SSID without password is not supported due to security concern. Please add password to your router.", nil)
                                     message:nil
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil]
          autorelease]
         show];
    }
    else
    {
        NSRange noQoute = NSMakeRange(1, _selectedWifiEntry.ssid_w_quote.length - 2);
        
        NSString *wifiName = [_selectedWifiEntry.ssid_w_quote substringWithRange:noQoute];
        NSString *homeWifi = [[NSUserDefaults standardUserDefaults] stringForKey:HOME_SSID];
        
        if ([wifiName isEqualToString:homeWifi])
        {
            [self moveToNextStep];
        }
        else
        {
            [self showDialogToConfirm:homeWifi selectedWifi:wifiName];
        }
    }
}

- (IBAction)btnRetryTouchUpInsideAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Methods

- (void)hubbleItemAction: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshWifiList
{
    //hide button back of navigation controller
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.btnContinue.enabled = NO;
    self.isAlreadyWifiList = FALSE;
    self.shouldTimeoutProcessing = FALSE;
    
    //clear list wifi
    [self.listOfWifi removeAllObjects];
    [self showIndicator];
    
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [self queryWifiList];
    
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

- (void)addOtherWifi
{
    WifiEntry * other = [[WifiEntry alloc]initWithSSID:@"\"Other Network\""];
    other.bssid = @"Other";
    other.auth_mode = @"None";
    other.signal_level = 0;
    other.noise_level = 0;
    other.quality = nil;
    other.encrypt_type = @"None";
    
    [self.listOfWifi addObject:other];
    [self filterCameraList];
    
    [other release];
}

- (void)moveToNextStep
{
    NSLog(@"Load step 6: Input network info");
    //Load the next xib
    NetworkInfoToCamera_VController *netWorkInfoViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        netWorkInfoViewController = [[NetworkInfoToCamera_VController alloc]
                                initWithNibName:@"NetworkInfoToCamera_VController_iPad" bundle:nil];
    }
    else
    {
        netWorkInfoViewController = [[NetworkInfoToCamera_VController alloc]
                                initWithNibName:@"NetworkInfoToCamera_VController" bundle:nil];
    }
    
    NSRange noQoute = NSMakeRange(1, _selectedWifiEntry.ssid_w_quote.length - 2);
    
    NSString *wifiName = [_selectedWifiEntry.ssid_w_quote substringWithRange:noQoute];
    
    [[NSUserDefaults standardUserDefaults] setObject:wifiName forKey:HOST_SSID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    netWorkInfoViewController.isOtherNetwork = [wifiName isEqualToString:@"Other Network"];
    
    netWorkInfoViewController.ssid = wifiName;
    netWorkInfoViewController.security = _selectedWifiEntry.auth_mode;
    
    [self.navigationController pushViewController:netWorkInfoViewController animated:NO];
    
    [netWorkInfoViewController release];
}

- (void)showDialogToConfirm: (NSString *)homeWifi selectedWifi: (NSString *)selectedWifi
{
    NSString * msg = [NSString stringWithFormat:@"You have selected wifi %@ which is not the same as your Home wifi, %@. If you choose to continue, there will more steps to setup your camera. Do you want to proceed?", selectedWifi, homeWifi];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil)
                                              otherButtonTitles:@"Continue", nil];
    alertView.tag = 555;
    [alertView show];
    [alertView release];
}

- (void)timeoutBLESetupProcessing:(NSTimer *)timer
{
    self.shouldTimeoutProcessing = TRUE;
    
    [[BLEConnectionManager getInstanceBLE].uartPeripheral didDisconnect];
    [BLEConnectionManager getInstanceBLE].delegate = nil;
    
    [self.viewProgress removeFromSuperview];
    [self.view addSubview:_viewError];
    [self.view bringSubviewToFront:_viewError];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{
    if (alertView.tag == ALERT_ASK_FOR_RETRY_WIFI_TAG)
    {
        switch(buttonIndex) {
            case 0:
                //TODO: Go back to camera detection screen
                
                break;
            case 1:
                NSLog(@"OK button pressed");
                
                //retry ..
                [self queryWifiList];
                
                break;
                
        }
        
    }
    else if (alertView.tag == RETRY_CONNECTION_BLE_FAIL_TAG)
    {
        if (_timerTimeoutConnectBLE)
        {
            [self.timerTimeoutConnectBLE invalidate];
            self.timerTimeoutConnectBLE = nil;
        }
        
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else if (alertView.tag == 555)
    {
        if (buttonIndex == 1) // Continue
        {
            [self moveToNextStep];
        }
    }
}

-(void) filterCameraList
{
    NSMutableArray * wifiList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_listOfWifi count]; i++)
    {
        WifiEntry * wifi = [_listOfWifi objectAtIndex:i];
        //        NSLog(@"SSID Wifi -------------------->%@", wifi.ssid_w_quote);
        if (![wifi.ssid_w_quote hasPrefix:@"\"Camera-"]
            &&![wifi.ssid_w_quote isEqualToString:@"\"\""]
            && ![wifi.ssid_w_quote hasPrefix:@"\"CameraHD-"])
        {
            [wifiList addObject:wifi];
            
        }
        
    }
    
    self.listOfWifi = wifiList;
    [wifiList release];
}

#pragma mark -
#pragma mark Table view delegates & datasource

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
    
    return _listOfWifi.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 1
    if (indexPath.section == 0)
    {
        if (indexPath.row < _listOfWifi.count - 1)
        {
            static NSString *CellIdentifier = @"Step05Cell";
            Step05Cell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Step05Cell" owner:nil options:nil];
            
            for (id curObj in objects)
            {
                if ([curObj isKindOfClass:[Step05Cell class]])
                {
                    cell = (Step05Cell *)curObj;
                    break;
                }
            }
            
            WifiEntry *entry = [_listOfWifi objectAtIndex:indexPath.row];
            cell.lblName.text = [entry.ssid_w_quote substringWithRange:NSMakeRange(1, entry.ssid_w_quote.length - 2)]; // Remove " & "
            
            return cell;
        }
        else
        {
            return _cellOtherNetwork;
        }
    }
    else
    {
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

    if (indexPath.section == 0)
    {
        self.btnContinue.enabled = YES;
        self.selectedWifiEntry = (WifiEntry *)[_listOfWifi objectAtIndex:indexPath.row];
    }
    else
    {
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

- (void) askForRetry
{
    //    [[BLEConnectionManager getInstanceBLE] disconnect];
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Fail_to_communicate_with_camera",nil, [NSBundle mainBundle],
                                                       @"Fail to communicate with camera. Retry?", nil);
    
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil);
    
    NSString * retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
                                                         @"Retry", nil);
    
    
    
    UIAlertView *_myAlert = nil ;
    _myAlert = [[UIAlertView alloc] initWithTitle:msg
                                          message:@""
                                         delegate:self
                                cancelButtonTitle:cancel
                                otherButtonTitles:retry,nil];
    
    _myAlert.tag = ALERT_ASK_FOR_RETRY_WIFI_TAG;
    _myAlert.delegate = self;
    
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
    [_myAlert setTransform:myTransform];
    [_myAlert show];
    [_myAlert release];
    
}

-(void) queryWifiList
{
    //after 60s will display for user get list wifi again
    //_timeout = [NSTimer scheduledTimerWithTimeInterval:3*60.0 target:self selector:@selector(showDialog:) userInfo:nil repeats:NO];
    /**
     * handle timeout: catch from uart and display time out at delegate returned.
     */
    
    //deday send command to camera BLE 1s.
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendCommandGetWifiList) userInfo:nil repeats:NO];
}

- (void)sendCommandGetWifiList
{
    //check state BLE
    if ([BLEConnectionManager getInstanceBLE].state != CONNECTED)
    {
        NSLog(@"BLE disconnected, can't sendCommandGetWifiList!!!!");
        return;
    }
    //retry sending get wifi
    NSLog(@"Send command get routers list, now!!!");
    [BLEConnectionManager getInstanceBLE].delegate = self;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION]; // 01.12.58
    
    
    if ([fwVersion compare:FW_MILESTONE] >= NSOrderedSame) // fw >= FW_MILESTONE
    {
        self.newCmdFlag = TRUE;
        [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_ROUTER_LIST2
                                                              withTimeOut:LONG_TIME_OUT_SEND_COMMAND];
    }
    else
    {
        self.newCmdFlag = FALSE;
        [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_ROUTER_LIST
                                                              withTimeOut:LONG_TIME_OUT_SEND_COMMAND];
    }
    
    NSDate * date;
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }    
}

- (void)dialogFailConnection:(NSTimer *)timer
{
    if ([BLEConnectionManager getInstanceBLE].state == CONNECTED)
    {
        //Check after TIME_OUT_RECONNECT_BLE seconds, if connected retrun
        return;
    }
    //show info
    NSString * msg = NSLocalizedStringWithDefaultValue(@"alert_mes_camera_ble_is_disconnected", nil, [NSBundle mainBundle], @"Camera (ble) is disconnected abruptly, please retry adding camera again", nil);
    
    
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil);
    
    
    
    UIAlertView *_myAlert = nil ;
    _myAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"error", nil, [NSBundle mainBundle], @"Error", nil)
                                          message:msg
                                         delegate:self
                                cancelButtonTitle:ok
                                otherButtonTitles:nil];
    
    _myAlert.tag = RETRY_CONNECTION_BLE_FAIL_TAG;
    _myAlert.delegate = self;
}

#pragma mark - BLEConnectionManagerDelegate

- (void) didReceiveData:(NSString *)string
{
    //NSLog(@"Data Receiving router list is %@", string);
    //processing data receive wifi list
    
    if (string !=nil && [string length] > 0)
    {
        NSData *router_list_raw = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        if (router_list_raw != nil)
        {
            WifiListParser * routerListParser = nil;
            routerListParser = [[WifiListParser alloc] initWithNewCmdFlag:_newCmdFlag];
            
            [routerListParser parseData:router_list_raw
                           whenDoneCall:@selector(setWifiResult:)
                          whenErrorCall:@selector(errorCallback:)
                                 target:self];
        }
        else
        {
            NSLog(@"GOT NULL wifi list from camera");
            [self queryWifiList];
        }
    }
    else
    {
        NSLog(@"%s GOT NULL response string.", __FUNCTION__);
        [self queryWifiList];
    }
}

- (void)reconnectBLE
{
    NSDate * date;
    date = [NSDate dateWithTimeInterval:2.0 sinceDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] runUntilDate:date];
    
    //[NSTimer scheduledTimerWithTimeInterval:TIME_OUT_RECONNECT_BLE target:self selector:@selector(dialogFailConnection:) userInfo:nil repeats:NO];
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [[BLEConnectionManager getInstanceBLE] reScanForPeripheral:[UARTPeripheral uartServiceUUID]];
}

-(void) bleDisconnected
{
    if (_shouldTimeoutProcessing)
    {
        NSLog(@"Timeout - BLE process takes too long time");
    }
    else
    {
        NSLog(@"BLE device is DISCONNECTED - Reconnect after 2s ");
        [self reconnectBLE];
    }
}

- (void) didConnectToBle:(CBUUID*) service_id
{
    NSLog(@"BLE device connected again(DisplayWifiList_VController) -isAlreadyWifiList: %d", _isAlreadyWifiList);
    if (!_isAlreadyWifiList)
    {
        [self queryWifiList];
    }
}

- (void)errorCallback: (NSError *)error
{
    NSLog(@"error return is %@", error);
    [self queryWifiList];
}
-(void) setWifiResult:(NSArray *) wifiList
{
    //show back button
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    if (_timerTimeoutConnectBLE)
    {
        [self.timerTimeoutConnectBLE invalidate];
        self.timerTimeoutConnectBLE = nil;
    }
    
    NSLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count);
    self.listOfWifi = [NSMutableArray arrayWithArray:wifiList];
    [self addOtherWifi];
    WifiEntry * entry;
    NSLog(@"List wifi after refreshing is:");
    for (int i =0; i< wifiList.count; i++)
    {
        entry = [wifiList objectAtIndex:i];
        NSLog(@"entry: %d, ssid_w_quote: %@, bssid: %@, auth_mode: %@, quality: %@", i, entry.ssid_w_quote, entry.bssid, entry.auth_mode, entry.quality);
    }
    
    self.isAlreadyWifiList = TRUE;
    
    //filter Camera list
    [self filterCameraList];
    [_mTableView reloadData];
    [self hideIndicator];
}

- (void) showDialog:(NSTimer *)timer
{
    [self askForRetry];
}

@end
