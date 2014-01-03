//
//  CreateBLEConnection_VController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 30/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "CreateBLEConnection_VController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Connect to camera BLE";
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back", nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    _currentBLEList = [[NSMutableArray alloc] init];
    [self.ib_lableStage setText:@"No connect"];
    [self.ib_NextStepAfterReady setEnabled:NO];
    
    [BLEManageConnect getInstanceBLE];
    [BLEManageConnect getInstanceBLE].delegate = self;
//    [self waiting_for_scan_cameraBLE];
}

- (void)waiting_for_scan_cameraBLE
{
    [self.ib_RefreshBLE setEnabled:NO];
    [self.ib_Indicator setHidden:NO];
    [self.ib_NextStepAfterReady setEnabled:NO];
    [self.ib_lableStage setText:@"Waiting for scanning BLE!"];
    [[BLEManageConnect getInstanceBLE] reScan];
    [BLEManageConnect getInstanceBLE].delegate = self;

    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(scanCameraBLEDone) userInfo:nil repeats:NO];
}

- (void)scanCameraBLEDone
{
    [self.ib_RefreshBLE setEnabled:YES];
    [self.ib_Indicator setHidden:YES];
    if ([_currentBLEList count] == 0)
    {
        [self.ib_lableStage setText:@"No found!"];
    } else if ([_currentBLEList count] == 1)
    {
        //Update UI
        [self.ib_lableStage setText:@"Waiting for connecting."];
        [self.ib_Indicator setHidden:NO];
        //Auto connect to BLE
        CBPeripheral *peripheralSelected =  [_currentBLEList objectAtIndex:0];
        [[BLEManageConnect getInstanceBLE] connectToBLEWithPeripheral:peripheralSelected];
        //Auto to next step to get mac address and version
        _timerUpdateUI = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateUIConnection:) userInfo:nil repeats:NO];
        
    } else
    {
        [self.ib_lableStage setText:@"Scan done."];
    }
    
}
- (void)updateUIConnection:(NSTimer *)info
{
    if ([BLEManageConnect getInstanceBLE].isOnBLE == NO)
    {
//        [self.ib_lableStage setText:@"disconnect, no ready"];
//        [self.ib_Indicator setHidden:YES];
        [self waiting_for_scan_cameraBLE];
        return;
    }
    
    [self.ib_Indicator setHidden:NO];
    [self.ib_NextStepAfterReady setEnabled:NO];
    if ([BLEManageConnect getInstanceBLE].state == IDLE)
    {
        [self.ib_lableStage setText:@"Waiting for connecting"];
    }
    else if ([BLEManageConnect getInstanceBLE].state == CONNECTED)
    {
        //stop timer update
        if (_timerUpdateUI)
        {
            [_timerUpdateUI invalidate];
            _timerUpdateUI = nil;
        }
        if ([_currentBLEList count] == 1)
        {
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(nextStepConnected:) userInfo:nil repeats:NO];
            return;
        }
        //Auto to next step to get mac address and version
        [self.ib_Indicator setHidden:YES];
        [self.ib_lableStage setText:@"Connected"];
        [self.ib_NextStepAfterReady setEnabled:YES];
        [self.ib_tableListBLE setExclusiveTouch:NO];
    }
    else
    {
        [self.ib_lableStage setText:@"disconnect, no ready"];
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
    [_ib_NextStepAfterReady release];
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

- (IBAction)nextStepConnected:(id)sender {
    //get list wifi and mac address
    if (_timerUpdateUI)
    {
        [_timerUpdateUI invalidate];
        _timerUpdateUI = nil;
    }
    [self moveToNextStep];
}

- (IBAction)refreshCamBLE:(id)sender {
    //stop timer update
    if (_timerUpdateUI)
    {
        [_timerUpdateUI invalidate];
        _timerUpdateUI = nil;
    }
    [self clearDataBLEConnection];
    
    if (_currentBLEList)
    {
        [_currentBLEList removeAllObjects];
    }
    [self.ib_tableListBLE reloadData];
    
    [self.ib_RefreshBLE setEnabled:NO];
    [self.ib_NextStepAfterReady setEnabled:NO];
    [self waiting_for_scan_cameraBLE];
}

-(void) setupFailedFWCheck
{
    NSLog(@"setupFailedFWCheck has failed ");
    //Go back to the beginning
    [UIApplication sharedApplication].idleTimerDisabled=  NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
}



- (void) checkConnectionToCamera:(NSTimer *) expired
{
    
}

#pragma mark - UARTPeripheralDelegate
- (void) onReceiveDataError:(int)error_code forCommand:(NSString *)commandToCamera
{
    
}
- (void) didReceiveData:(NSString *)fw_version
{
    NSLog(@"Receive string %@", fw_version);
    NSInteger lengMacAddress = [fw_version length];
    if ([fw_version hasPrefix:GET_VERSION])
    {
        [self.ib_Indicator setHidden:YES];
        //sucucessfull when writing version
        //diss miss statusDialog
        NSLog(@"get version successfull is %@", fw_version);


            NSRange colonRange = [fw_version rangeOfString:@": "];
            
            if (colonRange.location != NSNotFound)
            {
                NSString *fwVersion = [[fw_version componentsSeparatedByString:@": "] objectAtIndex:1];
                
                if ([fwVersion isEqualToString:@"-1"])
                    fwVersion = @"01_007_02";
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                
                
                [userDefaults setObject:fwVersion forKey:@"FW_VERSION"];
                //[userDefaults setObject:model forKey:@"MODEL"];
                [userDefaults synchronize];
            }
            
            NSLog(@"Load step 4");
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
            [self.navigationController pushViewController:step04ViewController animated:NO];
            
            [step04ViewController release];
 
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else
        if (lengMacAddress == 12)
        {
            //receive data mac address
            NSLog(@"Get mac address successfull");
            NSString *macAddress = fw_version;
            
            //processing for get mac address
            //mac address 44334C7E0C8A
            //try again send command version
            if ([macAddress isEqualToString:@"000000000000"])
            {
                //first get mac address of camera
                [BLEManageConnect getInstanceBLE].delegate = self;
                [[BLEManageConnect getInstanceBLE].uartPeripheral writeString:GET_MAC_ADDRESS];
                return;
            }
            self.cameraMac = fw_version;
            NSString *cameraNameFinal = [NSString stringWithFormat:@"Camera-%@", [fw_version substringFromIndex:6]];
            self.cameraName = cameraNameFinal;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            [userDefaults setObject:self.cameraMac forKey:@"CameraMacSave"];
            //[userDefaults setObject:model forKey:@"MODEL"];
            [userDefaults synchronize];
        }
}


- (void)sendCommandGetVersion
{
    NSLog(@"Get version, now");
    //first get mac address of camera
    [BLEManageConnect getInstanceBLE].delegate = self;
    [[BLEManageConnect getInstanceBLE].uartPeripheral writeString:GET_VERSION];
    
    NSDate * date;
    while ([BLEManageConnect getInstanceBLE].uartPeripheral.isBusy)
    {
        date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
}
-(void) moveToNextStep
{
    /*
     HttpCommunication * comm = [[HttpCommunication alloc] init];
     
     NSString * fw_version = [comm sendCommandAndBlock:GET_VERSION];
     [comm release];
     */
    [self.ib_Indicator setHidden:NO];
    [self.ib_lableStage setText:@"Getting info of camera"];
    
    [self sendCommandGetMacAddress:nil];
    [self sendCommandGetVersion];
}

- (void)sendCommandGetMacAddress:(NSTimer *)info
{
    //first get version of camera
    [BLEManageConnect getInstanceBLE].delegate = self;
    if (true)
    {
        [[BLEManageConnect getInstanceBLE].uartPeripheral writeString:GET_MAC_ADDRESS];
        NSDate * date;
        while ([BLEManageConnect getInstanceBLE].uartPeripheral.isBusy)
        {
            date = [NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]];
            
            [[NSRunLoop currentRunLoop] runUntilDate:date];
        }
    }
    else {
        
        NSString * msg = nil;
        NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        UIAlertView *alert;
        msg = @"Disconnect to BLE, plesea try to connect again.";
        alert = [[UIAlertView alloc]
                 initWithTitle:@""
                 message:msg
                 delegate:self
                 cancelButtonTitle:ok
                 otherButtonTitles:nil];
        
        
        alert.tag = TAG_TRY_CONNECT_BLE;
        
        [alert show];
        [alert release];
        
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
	NSArray *viewControllers = self.navigationController.viewControllers;
	if ([viewControllers indexOfObject:self] == NSNotFound)
    {
		// View is disappearing because it was popped from the stack
		NSLog(@"View controller was popped --- We are closing down..task_cancelled = YES");
        
		task_cancelled = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
    if (_timerUpdateUI != nil && [_timerUpdateUI isValid])
    {
        [_timerUpdateUI invalidate];
        _timerUpdateUI = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshCamBLE:nil];
}
- (void)clearDataBLEConnection
{
    [[BLEManageConnect getInstanceBLE].listBLEs removeAllObjects];
    [[BLEManageConnect getInstanceBLE].cm stopScan];
    [BLEManageConnect getInstanceBLE].state = IDLE;
}

- (void) didReceiveBLEList:(NSMutableArray *)bleLists
{
    _currentBLEList = bleLists;
    [self.ib_tableListBLE reloadData];
}
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
    CBPeripheral *peripheralSelected =  [[BLEManageConnect getInstanceBLE].listBLEs objectAtIndex:indexPath.row];
    [[BLEManageConnect getInstanceBLE] connectToBLEWithPeripheral:peripheralSelected];
    [self.ib_Indicator setHidden:NO];
    [self.ib_NextStepAfterReady setEnabled:NO];
    [self.ib_tableListBLE setExclusiveTouch:YES];
    _timerUpdateUI  = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                       target:self
                                                     selector:@selector(updateUIConnection:)
                                                     userInfo:nil
                                                      repeats:NO];
}
@end