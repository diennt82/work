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
#import "KISSMetricsAPI.h"

#define ALERT_CONFIRM_TAG       555
#define ALERT_RETRY_WIFI_TAG    559

@interface Step_05_ViewController () <UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellOtherNetwork;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellRefresh;
@property (retain, nonatomic) IBOutlet UIView *viewProgress;

@property (retain, nonatomic) WifiEntry *selectedWifiEntry;
@property (retain, nonatomic) WifiEntry *otherWiFi;
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
    self.otherWiFi = [[WifiEntry alloc]initWithSSID:@"\"Other Network\""];
    _otherWiFi.bssid = @"Other";
    _otherWiFi.auth_mode = @"None";
    _otherWiFi.signal_level = 0;
    _otherWiFi.noise_level = 0;
    _otherWiFi.quality = nil;
    _otherWiFi.encrypt_type = @"None";
    
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    [self performSelector:@selector(queryWifiList) withObject:nil afterDelay:0.001];
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
    /*
     * Stopped setup proccess if selected wifi is open. DO NOT support anymore!
     * The selected is HOME or not doesn't mater, just check to confirm.
     */
    
    if ([_selectedWifiEntry.auth_mode isEqualToString:@"open"])
    {
        [[[[UIAlertView alloc] initWithTitle:@"SSID without password is not supported due to security concern. Please add password to your router."
                                   message:nil
                                  delegate:nil
                         cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil]
          autorelease]
         show];
    }
    else
    {
        [[KISSMetricsAPI sharedAPI] recordEvent:@"Step05 - Touch continue button" withProperties:nil];
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
    NSString * msg = [NSString stringWithFormat:@"You have selected wifi %@ which is not the same as your Home wifi, %@. If you choose to continue, there will more steps to setup your camera. Do you want to proceed?", selectedWifi, homeWifi];
    
    UIAlertView *alertViewNotice = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];
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
    
   // [HttpCom instance].comWithDevice.device_port = 80;
    
    if ([fwVersion compare:FW_MILESTONE] >= NSOrderedSame) // fw >= FW_MILESTONE
    {
        router_list_raw = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:GET_ROUTER_LIST2
                                                                        withTimeout:2*DEFAULT_TIME_OUT];
        
        NSLog(@"%s - router_list_raw: %@", __FUNCTION__, [[NSString alloc] initWithData:router_list_raw encoding:NSUTF8StringEncoding]);
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
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    NSString * retry = NSLocalizedStringWithDefaultValue(@"Retry",nil, [NSBundle mainBundle],
                                                         @"Retry", nil);
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:msg
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:cancel
                                            otherButtonTitles:retry,nil];
    
    myAlert.tag = ALERT_RETRY_WIFI_TAG;
    [myAlert show];
    [myAlert release];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step05 - dismiss dialog with button index: %d", buttonIndex] withProperties:nil];
    
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
    [[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step05 - table view select row: %d in section: %d", indexPath.row, indexPath.section] withProperties:nil];
    
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


@end
