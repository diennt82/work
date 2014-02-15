//
//  CreateBLEConnection_VController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "CreateBLEConnection_VController.h"
#import "PublicDefine.h"

@interface CreateBLEConnection_VController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
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
        // [self.ib_lableStage setText:@"No BLE device found!"];
        [self.ib_RefreshBLE setEnabled:NO];
        [self.ib_Indicator setHidden:NO];
        
        
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
        [self.ib_RefreshBLE setEnabled:YES];
        [self.ib_Indicator setHidden:YES];
        [self.ib_tableListBLE setHidden:NO];
        
         [[BLEConnectionManager getInstanceBLE].cm stopScan];
        
        //Update UI
        [self.ib_lableStage setText:@"Select a device to connect"];
        
        [self.ib_tableListBLE reloadData];
        // Don't Auto connect to BLE
        //
        //        CBPeripheral *peripheralSelected =  [_currentBLEList objectAtIndex:0];
        //        [[BLEConnectionManager getInstanceBLE].cm stopScan];
        //
        //        [[BLEConnectionManager getInstanceBLE] connectToBLEWithPeripheral:peripheralSelected];
        
    }
    else //More than 2 camera in  5sec
    {
        [self.ib_RefreshBLE setEnabled:YES];
        [self.ib_Indicator setHidden:YES];
                [self.ib_tableListBLE setHidden:NO]; 
        
        [[BLEConnectionManager getInstanceBLE].cm stopScan];
        
        [self.ib_lableStage setText:@"Select a device to connect."];
        [self.ib_tableListBLE reloadData];
        
        
    }
    
}
- (void)dismissIndicator
{
    _timeOutWaitingConnectBLE = nil;
    [self.ib_Indicator setHidden:YES];
    [self.ib_lableStage setText:@"Can't connect to BLE, please press refresh button"];
}


/* This is called when BLE is connected & RX, TX characteristic is found
 */
- (void)updateUIConnection:(NSTimer *)info
{
    
    ////???? Do i need this
//    _timeOutWaitingConnectBLE = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(dismissIndicator) userInfo:nil repeats:NO];
    
    [self.ib_Indicator setHidden:NO];
    
    if ([BLEConnectionManager getInstanceBLE].state == CONNECTED)
    {
        
        /* Start sending commands now */
        [self moveToNextStep];
        
        [self.ib_tableListBLE setExclusiveTouch:YES];
    }
    else
    {
        NSLog(@"updateUIConnection : BLE state is %d, not CONNECTED", [BLEConnectionManager getInstanceBLE].state);
    }
}
- (void)viewDidUnload
{
    [self setIb_tableListBLE:nil];
    [self setIb_Indicator:nil];
    [self setIb_RefreshBLE:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}


#pragma mark -
#pragma mark Rotating
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));}

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
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
    // Load resources for iOS 7 or later
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //[[NSBundle mainBundle] loadNibNamed:@"Step_03_ViewController_land_ipad" owner:self options:nil];
        }
        else
        {
            BOOL hidden = self.inProgress.hidden;
            [self.inProgress removeFromSuperview];
            
            
            //[[NSBundle mainBundle] loadNibNamed:@"Step_03_ViewController_land" owner:self options:nil];
            
            [self.view addSubview:self.inProgress];
            self.inProgress.hidden = hidden;
            
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //[[NSBundle mainBundle] loadNibNamed:@"Step_03_ViewController_ipad" owner:self options:nil];
        }
        else
        {
            BOOL hidden = self.inProgress.hidden;
            [self.inProgress removeFromSuperview];
            //[[NSBundle mainBundle] loadNibNamed:@"Step_03_ViewController" owner:self options:nil];
            [self.view addSubview:self.inProgress];
            self.inProgress.hidden = hidden;
        }
    }
    
    //    }
}
#pragma mark -

-(void) dealloc
{
    [homeWifiSSID release];
    [inProgress release];
    [_ib_lableStage release];
    
    [_ib_tableListBLE release];
    [_ib_Indicator release];
    [_ib_RefreshBLE release];
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
        [self.ib_Indicator setHidden:YES];
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
    [self.ib_Indicator setHidden:NO];
    [self.ib_lableStage setText:@"Getting info from camera"];
    
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



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentBLEList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    CBPeripheral *peripheral = [_currentBLEList objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
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

    
    
    
}
@end