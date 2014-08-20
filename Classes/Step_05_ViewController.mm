//
//  Step_05_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/25/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_05_ViewController.h"
#import "Step05Cell.h"
#import "HttpCom.h"
#import "Step_04_ViewController.h"
//#import "KISSMetricsAPI.h"
#import "HoldOnCamWifi.h"
#import "CustomIOS7AlertView.h"
#import "Step_10_ViewController.h"
#import "PublicDefine.h"
#import "UIView+Custom.h"

#define ALERT_CONFIRM_TAG       555
#define ALERT_RETRY_WIFI_TAG    559
#define GAI_CATEGORY            @"Step 05 view"

@interface Step_05_ViewController () <UIAlertViewDelegate, CustomIOS7AlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellOtherNetwork;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellRefresh;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;
@property (retain, nonatomic) IBOutlet UIButton *btnSkipWifiSetup;

@property (retain, nonatomic) WifiEntry *selectedWifiEntry;
@property (retain, nonatomic) WifiEntry *otherWiFi;
@property (retain, nonatomic) CustomIOS7AlertView *alertView;

@end

@implementation Step_05_ViewController

@synthesize listOfWifi;
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
    [listOfWifi release];
    [_cellOtherNetwork release];
    [_btnContinue release];
    [_cellRefresh release];
    [_viewProgress release];
    [_otherWiFi release];
    [_btnSkipWifiSetup release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self xibDefaultLocalization];
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    
    self.trackedViewName = GAI_CATEGORY;
    
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
    
    //Create an entry for "Other.."
    WifiEntry *wifiEntry = [[WifiEntry alloc] initWithSSID:@"\"Other Network\""];
    wifiEntry.bssid = @"Other";
    wifiEntry.auth_mode = @"None";
    wifiEntry.signal_level = 0;
    wifiEntry.noise_level = 0;
    wifiEntry.quality = nil;
    wifiEntry.encrypt_type = @"None";
    self.otherWiFi = wifiEntry;
    [wifiEntry release];
    
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    [self performSelector:@selector(queryWifiList) withObject:nil afterDelay:0.001];
    
    [[HoldOnCamWifi shareInstance] startHolder];
    
    if (_camProfile) // Focus73
    {
        self.btnSkipWifiSetup.titleLabel.text = NSLocalizedStringWithDefaultValue(@"skip_wifi_setup",
                                                                                  nil, [NSBundle mainBundle],
                                                                                  @"Skip WIFI Setup", nil);
        self.btnSkipWifiSetup.hidden = NO;
    }
}

- (void)xibDefaultLocalization
{
    [[self.view viewWithTag:1] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step05_label_selected_wifi_network", nil, [NSBundle mainBundle], @"Select Wi-Fi Network to Connect Camera", nil)];
    [[self.view viewWithTag:2] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step05_label_select_your_own trusted_network", nil, [NSBundle mainBundle], @"Select your own trusted network.", nil)];
    [[self.view viewWithTag:3] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step05_label_password_protected", nil, [NSBundle mainBundle], @"(It must be password protected.)", nil)];
    [[self.view viewWithTag:4] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step05_label_detected_wifi_network", nil, [NSBundle mainBundle], @"Detected Wi-Fi Network", nil)];
    
    [self.btnSkipWifiSetup setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step05_button_skip_wifi_settup", nil, [NSBundle mainBundle], @"Skip WIFI Setup", nil)];
    [self.btnContinue setTitle:NSLocalizedStringWithDefaultValue(@"xib_step05_button_continue", nil, [NSBundle mainBundle], @"Continue", nil) forState:UIControlStateNormal];
    
    [[self.viewProgress viewWithTag:1] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step05_label_search_wifi_network", nil, [NSBundle mainBundle], @"Searching for Wi-Fi Networks", nil)];

    [[self.viewProgress viewWithTag:2] setLocalizationText: NSLocalizedStringWithDefaultValue(@"xib_step05_label_please_wait", nil, [NSBundle mainBundle], @"Please wait", nil)];
    
    [[self.cellOtherNetwork viewWithTag:1] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step05_cell_other_network", nil, [NSBundle mainBundle], @"Other Network", nil)];
    
    [[self.cellRefresh viewWithTag:1] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step05_cell_refresh", nil, [NSBundle mainBundle], @"Refresh", nil)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) filterCameraList
{
    NSMutableArray * wifiList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [listOfWifi count]; i++)
    {
        WifiEntry * wifi = [listOfWifi objectAtIndex:i];
//        NSLog(@"SSID Wifi -------------------->%@", wifi.ssid_w_quote);
        if (![wifi.ssid_w_quote hasPrefix:@"\"Camera-"] &&
            ![wifi.ssid_w_quote isEqualToString:@"\"\""] &&
            ![wifi.ssid_w_quote hasPrefix:@"\"CameraHD-"])
        {
            [wifiList addObject:wifi];
            
        }
    }
    
    self.listOfWifi = wifiList;
    [wifiList release];
}

#pragma mark - Actions
- (void)hubbleItemAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnContinueTouchUpInsideAction:(id)sender
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Touch up inside continue button"
                                                     withLabel:@"Continue"
                                                     withValue:nil];
    /*
     * Stopped setup proccess if selected wifi is open. DO NOT support anymore!
     * The selected is HOME or not doesn't mater, just check to confirm.
     */
    
    if ([_selectedWifiEntry.auth_mode isEqualToString:@"open"])
    {
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_inform_add_password_to_your_router", nil, [NSBundle mainBundle], @"SSID without password is not supported due to security concern. Please add password to your router.", nil)
                                   message:nil
                                  delegate:nil
                         cancelButtonTitle:nil
                           otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil]
          autorelease]
         show];
    }
    else
    {
        //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step05 - Touch continue button" withProperties:nil];
        
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

- (IBAction)btnSkipWifiSetupTouchUpInsideAction:(id)sender
{
    [self createHubbleAlertView];
    
    [self performSelectorInBackground:@selector(configureCameraAndMoveToFinalStep) withObject:NO];
}

#pragma mark - Methods

- (void)moveToNextStep
{
    NSLog(@"Load step 6");
    //Load the next xib
    Step_06_ViewController *step06ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        step06ViewController = [[Step_06_ViewController alloc]
                                initWithNibName:@"Step_06_ViewController_ipad" bundle:nil];
    }
    else
    {
        step06ViewController = [[Step_06_ViewController alloc]
                                initWithNibName:@"Step_06_ViewController" bundle:nil];
    }
    
    NSRange noQoute = NSMakeRange(1, _selectedWifiEntry.ssid_w_quote.length - 2);

    NSString *wifiName = [_selectedWifiEntry.ssid_w_quote substringWithRange:noQoute];
    
    [[NSUserDefaults standardUserDefaults] setObject:wifiName forKey:HOST_SSID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    step06ViewController.isOtherNetwork = [wifiName isEqualToString:@"Other Network"];
    
    step06ViewController.ssid = wifiName;
    step06ViewController.security = _selectedWifiEntry.auth_mode;
    
    [self.navigationController pushViewController:step06ViewController animated:NO];
    
    [step06ViewController release];
}

- (void)showDialogToConfirm: (NSString *)homeWifi selectedWifi: (NSString *)selectedWifi
{
    NSString *wifi = selectedWifi;
    if ([selectedWifi isEqualToString:@"Other Network"])
    {
        wifi = NSLocalizedStringWithDefaultValue(@"xib_step05_cell_other_network", nil, [NSBundle mainBundle], @"Other Network", nil);
    }
    NSString * msg = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"alert_mes_dialog_to_confirm_selected_wifi", nil, [NSBundle mainBundle], @"You have selected wifi %@ which is not the same as your Home wifi, %@. If you choose to continue, there will more steps to setup your camera. Do you want to proceed?", nil), wifi, homeWifi];
    
    UIAlertView *alertViewNotice = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"notice", nil, [NSBundle mainBundle],  @"Notice", nil)
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil)
                                              otherButtonTitles:NSLocalizedStringWithDefaultValue(@"continue", nil, [NSBundle mainBundle], @"Continue", nil), nil];
    alertViewNotice.tag = ALERT_CONFIRM_TAG;
    [alertViewNotice show];
    [alertViewNotice release];
}

-(void) queryWifiList
{
    NSLog(@"Step_05_VC - queryWifiList. Waiting...");
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    
    NSData * router_list_raw;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION]; // 01.12.58
    
    BOOL newCmdFlag = TRUE;
    
   /*
    * 1. Using RT command if fw >= FW_MILESTONE
    * 2. Using RT command if this camera is Focus73 model.
    */
    
    if ([fwVersion compare:FW_MILESTONE] >= NSOrderedSame || _camProfile) // fw >= FW_MILESTONE
    {
        router_list_raw = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:GET_ROUTER_LIST2
                                                                        withTimeout:2*DEFAULT_TIME_OUT];
        
        //NSLog(@"%s - router_list_raw: %@", __FUNCTION__, [[NSString alloc] initWithData:router_list_raw encoding:NSUTF8StringEncoding]);
    }
    else
    {
        newCmdFlag = FALSE;
        router_list_raw = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:GET_ROUTER_LIST
                                                                        withTimeout:2*DEFAULT_TIME_OUT];
    }
    
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
    if (router_list_raw != nil)
    {
        WifiListParser *routerListParser = [[[WifiListParser alloc]initWithNewCmdFlag:newCmdFlag] autorelease];
        
        [routerListParser parseData:router_list_raw
                       whenDoneCall:@selector(setWifiResult:)
                             target:self];
    }
    else
    {
        NSLog(@"GOT NULL wifi list from camera");
        [self askForRetry];
    }
}

- (void) askForRetry
{
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Fail_to_communicate_with_camera",nil, [NSBundle mainBundle],
                                                       @"Fail to communicate with camera. Retry?", nil);
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"cancel", nil, [NSBundle mainBundle], @"Cancel", nil);
    NSString * retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle], @"Retry", nil);
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:msg
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:cancel
                                            otherButtonTitles:retry,nil];
    
    myAlert.tag = ALERT_RETRY_WIFI_TAG;
    [myAlert show];
    [myAlert release];
}

- (void)configureCameraAndMoveToFinalStep
{
    [self configureCamera];
    
    [[NSUserDefaults standardUserDefaults] setObject:[CameraPassword fetchSSIDInfo] forKey:HOST_SSID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSelectorOnMainThread:@selector(moveToFinalStep) withObject:nil waitUntilDone:NO];
}

- (void)configureCamera
{
    /*
     * 1. Set Auth.
     * 2. Default on all of PN.
     * 3. Get UDID
     * 4. Restart systems.
     */
    
    // 1.
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ZZZ"];
    
    NSMutableString *stringFromDate = [NSMutableString stringWithString:[formatter stringFromDate:now]];
    [formatter release];
    [stringFromDate insertString:@"." atIndex:3];
    
    NSString * set_auth_cmd = [NSString stringWithFormat:@"%@%@%@%@%@",
                               SET_SERVER_AUTH,
                               SET_SERVER_AUTH_PARAM1, [[NSUserDefaults standardUserDefaults] stringForKey:@"PortalApiKey"],
                               SET_SERVER_AUTH_PARAM2, stringFromDate];
    
    NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:set_auth_cmd
                                                                   withTimeout:10.0];
    NSLog(@"set auth -set_auth_cmd: %@, -response: %@ ", set_auth_cmd, response);
    
    // 2.
    [self defaultOnAllPNToCamera];
    
    // 3.
    NSString *stringUDID = @"";
    NSString *stringMac = @"00:00:00:00:00";
    
    response = [[HttpCom instance].comWithDevice sendCommandAndBlock:GET_UDID
                                                         withTimeout:5.0];
    
    NSString *pattern = [NSString stringWithFormat:@"^%@: [0-9A-Z]{26}$", GET_UDID];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    if (!regex)
    {
        NSLog(@"%s error:%@", __FUNCTION__, error.description);
    }
    else
    {
        NSLog(@"%s respone:%@", __FUNCTION__, response);
        
        if (response)
        {
            //get_udid: 01008344334C32B0A0VFFRBSVA
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:response
                                                                options:0
                                                                  range:NSMakeRange(0, [response length])];
            NSLog(@"%s numberOfMatches:%lu", __FUNCTION__, (unsigned long)numberOfMatches);
            
            if (numberOfMatches == 1)
            {
                stringUDID = [response substringFromIndex:GET_UDID.length + 2];
                stringMac = [Util add_colon_to_mac:[stringUDID substringWithRange:NSMakeRange(6, 12)]];
            }
        }
    }
    //save mac address for used later
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:stringMac forKey:@"CameraMacWithQuote"];
    [userDefaults setObject:stringUDID forKey:CAMERA_UDID];
    [userDefaults synchronize];
    
    // 4.
    response = [[HttpCom instance].comWithDevice sendCommandAndBlock:RESTART_HTTP_CMD];
    
    NSLog(@"%s RESTART_HTTP_CMD: %@", __FUNCTION__, response);
}

- (void)defaultOnAllPNToCamera
{
    NSString *result = @"";
    
    NSString *response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"set_motion_area&grid=1x1&zone=00"];
    result = [result stringByAppendingString:response];
    
    if (!_camProfile) // Meaning this is not a Focus73 model!
    {
        response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"vox_enable"];
        result = [result stringByAppendingFormat:@", %@", response];
        
        response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"set_temp_lo_enable&value=1"];
        result = [result stringByAppendingFormat:@", %@", response];
        
        response = [[HttpCom instance].comWithDevice sendCommandAndBlock:@"set_temp_hi_enable&value=1"];
        result = [result stringByAppendingFormat:@", %@", response];
    }
    
    NSLog(@"%s respnse:%@", __FUNCTION__, result);
}

- (void)moveToFinalStep
{
    //[MBProgressHUD hideHUDForView:self.view animated:NO];
    [self customIOS7dialogButtonTouchUpInside:_alertView clickedButtonAtIndex:0];
    
    Step_10_ViewController *step10ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        
        step10ViewController = [[Step_10_ViewController alloc]
                                initWithNibName:@"Step_10_ViewController_ipad" bundle:nil];
    }
    else
    {
        
        step10ViewController = [[Step_10_ViewController alloc]
                                initWithNibName:@"Step_10_ViewController" bundle:nil];
    }
    
    [self.navigationController pushViewController:step10ViewController animated:NO];
    [step10ViewController release];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step05 - dismiss dialog with button index: %d", buttonIndex] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Dismiss alert: %d", alertView.tag]
                                                     withLabel:[NSString stringWithFormat:@"Alert %@", alertView.title]
                                                     withValue:nil];
    
    if (alertView.tag == ALERT_RETRY_WIFI_TAG)
    {
        switch(buttonIndex) {
            case 0:
                //TODO: Go back to camera detection screen
                [self.navigationController popViewControllerAnimated:YES];
                break;
                
            case 1:
            {
                [self.view addSubview:_viewProgress];
                [self.view bringSubviewToFront:_viewProgress];
                
                NSLog(@"OK button pressed");
                //retry ..
                 [self performSelectorInBackground:@selector(queryWifiList) withObject:nil];
            }
                break;
                
            default:
                break;
        }
    }
    else if(alertView.tag == ALERT_CONFIRM_TAG)
    {
        if (buttonIndex == 1) // Continue
        {
            [self moveToNextStep];
        }
    }
    else
    {
        NSLog(@"Step_05_VC - alertDismiss: %d", alertView.tag);
    }
}

#pragma mark - WifiListParse delegate

-(void) setWifiResult:(NSArray *) wifiList
{
    NSLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count);
    //hide progressView
    [_viewProgress removeFromSuperview];

    WifiEntry * entry;

    for (int i = 0; i < wifiList.count; i++)
    {
        entry = [wifiList objectAtIndex:i];
        NSLog(@"entry: %d, ssid_w_quote: %@, bssid: %@, auth_mode: %@, quality: %@", i, entry.ssid_w_quote, entry.bssid, entry.auth_mode, entry.quality);
    }
    
    self.listOfWifi = [NSMutableArray arrayWithArray:wifiList];
    
    [self.listOfWifi addObject:_otherWiFi];
    [self filterCameraList];
    [mTableView reloadData];
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
    
    return listOfWifi.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row < listOfWifi.count - 1)
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
            
            WifiEntry *entry = [listOfWifi objectAtIndex:indexPath.row];
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
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step05 - table view select row: %d in section: %d", indexPath.row, indexPath.section] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Select Wifi entry"
                                                     withLabel:@"Row"
                                                     withValue:[NSNumber numberWithInteger:indexPath.row]];
    
    if (indexPath.section == 0)
    {
        self.btnContinue.enabled = YES;
        self.selectedWifiEntry = (WifiEntry *)[listOfWifi objectAtIndex:indexPath.row];
    }
    else
    {
        [self.view addSubview:_viewProgress];
        [self.view bringSubviewToFront:_viewProgress];
        
        [self performSelectorInBackground:@selector(queryWifiList) withObject:nil];
    }
}

- (void)createHubbleAlertView
{
    // Here we need to pass a full frame
    
    if (_alertView == nil)
    {
        self.alertView = [[CustomIOS7AlertView alloc] init];
        // Add some custom content to the alert view
        [_alertView setContainerView:[self createDemoView]];
        
        // Modify the parameters
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 200, 41)];// autorelease];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.text = NSLocalizedStringWithDefaultValue(@"waiting_for_configure_camera", nil, [NSBundle mainBundle], @"Waiting for configure camera...", nil);
    [demoView addSubview:label];
    [label release];
    
    return demoView;
}


@end
