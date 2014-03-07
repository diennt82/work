//
//  DisplayWifiList_VController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "DisplayWifiList_VController.h"
#import "Step05Cell.h"

@interface DisplayWifiList_VController () <UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell *cellOtherNetwork;
@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UITableView *mTableView;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;

@property (retain, nonatomic) WifiEntry *selectedWifiEntry;

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
    [_refreshWifiList release];
    [_ib_Indicator release];
    [_ib_LabelState release];
    [_cellOtherNetwork release];
    [_btnContinue release];
    [_mTableView release];
    [_viewProgress release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
#if 1
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
    
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
#else
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Configure_Camera",nil, [NSBundle mainBundle],
                                                                  @"Configure Camera" , nil);
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    self.navigationItem.hidesBackButton=YES;
    //
    [BLEConnectionManager getInstanceBLE].delegate = self;
    _listOfWifi = [[NSMutableArray alloc] init];
    
    //show process view to get wifi list
    [self showIndicator];
    //set text
    NSString *waitingGetWifiText = NSLocalizedStringWithDefaultValue(@"waiting_get_wifi_list",nil, [NSBundle mainBundle],
                                                              @"Waiting for get wifi list..." , nil);
    
    [self.ib_LabelState setText:waitingGetWifiText];
//    [self queryWifiList];
#endif
}

-(void) viewWillAppear:(BOOL)animated
{
    //delay .1s to display new screen
    [super viewWillAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(queryWifiList) userInfo:nil repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear of DisplayWifiList_VController");
    //[self hideIndicator];
    [_viewProgress removeFromSuperview];
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

#pragma mark - Methods

- (void)hubbleItemAction: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    NetworkInfoToCamera_VController *netWorkInfoViewController = [[NetworkInfoToCamera_VController alloc] initWithNibName:@"NetworkInfoToCamera_VController" bundle:nil];
    
    NSRange noQoute = NSMakeRange(1, _selectedWifiEntry.ssid_w_quote.length - 2);
    
    NSString *wifiName = [_selectedWifiEntry.ssid_w_quote substringWithRange:noQoute];
    
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
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];
    alertView.tag = 555;
    [alertView show];
    [alertView release];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listOfWifi.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 1
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
#if 1
    self.btnContinue.enabled = YES;
    self.selectedWifiEntry = (WifiEntry *)[_listOfWifi objectAtIndex:indexPath.row];
#else
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
    int tag = tableView.tag;
    if (tag == 11)
    {
        int idx=indexPath.row;
        
        WifiEntry *entry = [_listOfWifi objectAtIndex:idx];
        
        //load step 06
        NSLog(@"Load step 6: Input network info");
        //Load the next xib
        NetworkInfoToCamera_VController *netWorkInfoViewController = nil;
        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            
//            step06ViewController = [[NetworkInfoToCamera_VController alloc]
//                                    initWithNibName:@"NetworkInfoToCamera_VController_iPad" bundle:nil];
//            
//        }
//        else
        {
            
            netWorkInfoViewController = [[NetworkInfoToCamera_VController alloc]
                                    initWithNibName:@"NetworkInfoToCamera_VController" bundle:nil];
            
            
        }
        
        
        
        
        
        NSRange noQoute = NSMakeRange(1, [entry.ssid_w_quote length]-2);
        if ([[entry.ssid_w_quote substringWithRange:noQoute] isEqualToString:@"Other Network"])
        {
            netWorkInfoViewController.isOtherNetwork = TRUE;
        }
        else
        {
            netWorkInfoViewController.isOtherNetwork = FALSE;
        }
        netWorkInfoViewController.ssid = [entry.ssid_w_quote substringWithRange:noQoute];
        netWorkInfoViewController.security = entry.auth_mode;
        
        [self.navigationController pushViewController:netWorkInfoViewController animated:NO];
        
        [netWorkInfoViewController release];
        
    }
#endif
}
#pragma mark -

-(void) handleButtonPressed:(id) sender
{
    
}
- (void)showIndicator
{
    [self.view bringSubviewToFront:self.ib_Indicator];
    [self.ib_Indicator setHidden:NO];
}

- (void)hideIndicator
{
    [self.ib_Indicator setHidden:YES];
}

- (void) askForRetry
{
    //    [[BLEConnectionManager getInstanceBLE] disconnect];
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Fail_to_communicate_with_camera",nil, [NSBundle mainBundle],
                                                       @"Fail to communicate with camera. Retry?", nil);
    
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
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

- (IBAction)performRefreshWifiList:(id)sender {
    
    //hide button back of navigation controller
    self.navigationItem.hidesBackButton = YES;
    //disable button refresh
    [self.refreshWifiList setEnabled:NO];
    
    //clear list wifi
    [self.listOfWifi removeAllObjects];
    // reload tableview
    [_mTableView reloadData];
    
    [self showIndicator];
    [BLEConnectionManager getInstanceBLE].delegate = self;
    [self queryWifiList];
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
    [[BLEConnectionManager getInstanceBLE].uartPeripheral writeString:GET_ROUTER_LIST withTimeOut:LONG_TIME_OUT_SEND_COMMAND];
    NSDate * date;
    while ([BLEConnectionManager getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
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
    NSString * msg =  @"Camera (ble) is disconnected abruptly, please retry adding camera again";
    
    
    
    NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                      @"Ok", nil);
    
    
    
    UIAlertView *_myAlert = nil ;
    _myAlert = [[UIAlertView alloc] initWithTitle:@"Error"
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
    NSLog(@"Data Receiving router list is %@", string);
    {
        //processing data receive wifi list
        
        if (string !=nil && [string length] > 0)
        {
            NSData *router_list_raw = [string dataUsingEncoding:NSUTF8StringEncoding];
            
            if (router_list_raw != nil)
            {
                WifiListParser * routerListParser = nil;
                routerListParser = [[WifiListParser alloc]init];
                
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
            //string received is nil
            [self queryWifiList];
        }
        
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
    NSLog(@"BLE device is DISCONNECTED - Reconnect after 2s ");
    [self reconnectBLE];
}

- (void) didConnectToBle:(CBUUID*) service_id
{
    NSLog(@"BLE device connected again(DisplayWifiList_VController)");
    [self queryWifiList];
}

- (void)errorCallback: (NSError *)error
{
    NSLog(@"error return is %@", error);
    [self queryWifiList];
}
-(void) setWifiResult:(NSArray *) wifiList
{
    //show back button
    self.navigationItem.hidesBackButton = YES;
    //enable button refresh
    [self.refreshWifiList setEnabled:YES];
    //hide indicarot
    //[self hideIndicator];
    [_viewProgress removeFromSuperview];
    
    NSLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count);
    self.listOfWifi = [NSMutableArray arrayWithArray:wifiList];
    [self addOtherWifi];
    WifiEntry * entry;
    NSLog(@"List wifi after refreshing is:");
    for (int i =0; i< wifiList.count; i++)
    {
        entry = [wifiList objectAtIndex:i];
        NSLog(@"entry %d : %@",i, entry.ssid_w_quote);
        NSLog(@"entry %d : %@",i, entry.bssid);
        NSLog(@"entry %d : %@",i, entry.auth_mode);
        NSLog(@"entry %d : %@",i, entry.quality);
    }
    
    //filter Camera list
    [self filterCameraList];
    
    [_mTableView reloadData];
}

- (void) showDialog:(NSTimer *)timer
{
    [self askForRetry];
}
@end
