//
//  DisplayWifiList_VController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "DisplayWifiList_VController.h"

@interface DisplayWifiList_VController ()

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
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated
{
    //delay .1s to display new screen
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(queryWifiList) userInfo:nil repeats:NO];
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear of DisplayWifiList_VController");
    [self hideIndicator];
    //remove delegate
    [BLEConnectionManager getInstanceBLE].delegate = nil;
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
#pragma mark Rotating
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustViewsForOrientations:toInterfaceOrientation];
}

-(void) adjustViewsForOrientations: (UIInterfaceOrientation) interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            
            
            
        }
        else
        {
            //[[NSBundle mainBundle] loadNibNamed:@"Step_05_ViewController_land" owner:self options:nil];
        }
        //        mTableView.frame = CGRectMake(mTableView.frame.origin.x,
        //                                      mTableView.frame.origin.y,
        //                                      mTableView.frame.size.width,
        //                                      //550);
        //                                      UIScreen.mainScreen.bounds.size.width - mTableView.frame.origin.y - 84);
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
        }
        else
        {
            //[[NSBundle mainBundle] loadNibNamed:@"Step_05_ViewController" owner:self options:nil];
        }
        
        //        mTableView.frame = CGRectMake(mTableView.frame.origin.x,
        //                                      mTableView.frame.origin.y,
        //                                      mTableView.frame.size.width,
        //                                      //500);
        //                                      UIScreen.mainScreen.bounds.size.height - mTableView.frame.origin.y - 84);
    }
}

#pragma mark -
#pragma mark Table view delegates & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int tag = tableView.tag;
    if (tag == 11)
        return 1;
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tag = tableView.tag;
    if (tag == 11)
        return [_listOfWifi count];
    return 0;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = @"Select the wifi connection that your camera can use";
    
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    
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
    [mTableView reloadData];
    
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
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
    if (alertView.tag == RETRY_CONNECTION_BLE_FAIL_TAG)
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
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
    self.navigationItem.hidesBackButton = NO;
    //enable button refresh
    [self.refreshWifiList setEnabled:YES];
    //hide indicarot
    [self hideIndicator];
    
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
    
    [mTableView reloadData];
}

- (void) showDialog:(NSTimer *)timer
{
    [self askForRetry];
}
@end
