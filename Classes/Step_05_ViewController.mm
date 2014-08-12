//
//  Step_05_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/25/12.
//  Copyright (c) 2012 Hubble Connected Ltd. All rights reserved.
//

#import "Step_05_ViewController.h"
#import "Step_04_ViewController.h"
#import "Step05Cell.h"
#import "HttpCom.h"

@interface Step_05_ViewController () <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellView;
@property (nonatomic, weak) IBOutlet UIButton *btnContinue;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellOtherNetwork;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellRefresh;
@property (nonatomic, weak) IBOutlet UIView *viewProgress;

@property (nonatomic, strong) WifiEntry *selectedWifiEntry;
@property (nonatomic, strong) WifiEntry *otherWiFi;

@end

@implementation Step_05_ViewController

#define ALERT_CONFIRM_TAG       555
#define ALERT_RETRY_WIFI_TAG    559
#define GAI_CATEGORY @"Step 05 view"

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    [_btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [_btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    _btnContinue.enabled = NO;
    
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
    self.otherWiFi = [[WifiEntry alloc] initWithSSID:@"\"Other Network\""];
    _otherWiFi.bssid = @"Other";
    _otherWiFi.authMode = @"None";
    _otherWiFi.signalLevel = 0;
    _otherWiFi.noiseLevel = 0;
    _otherWiFi.quality = nil;
    _otherWiFi.encryptType = @"None";
    
    [self.view addSubview:_viewProgress];
    [self.view bringSubviewToFront:_viewProgress];
    
    [self performSelector:@selector(queryWifiList) withObject:nil afterDelay:0.001];
}

#pragma mark - Private methods

// Filters wifi access points that match our cameras naming pattern. Kind of a
// hack way to do it but the likelyhood of anyone naming a normal access point
// with a "Camera-" or "CameraHD-" name is not very high.
- (void)filterCameraList
{
    NSMutableArray *wifiList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _listOfWifi.count; i++) {
        WifiEntry *wifi = _listOfWifi[i];
        if (![wifi.ssidWithQuotes hasPrefix:@"\"Camera-"] &&
            ![wifi.ssidWithQuotes isEqualToString:@"\"\""] &&
            ![wifi.ssidWithQuotes hasPrefix:@"\"CameraHD-"])
        {
            [wifiList addObject:wifi];
        }
    }
    
    self.listOfWifi = wifiList;
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
    
    if ([_selectedWifiEntry.authMode isEqualToString:@"open"]) {
        [[[UIAlertView alloc] initWithTitle:@"SSID without password is not supported due to security concern. Please add password to your router."
                                   message:nil
                                  delegate:nil
                         cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil] show];
    }
    else {
        //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step05 - Touch continue button" withProperties:nil];
        
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

#pragma mark - Methods

- (void)moveToNextStep
{
    NSLog(@"Load step 6");
    
    //Load the next xib
    Step_06_ViewController *step06ViewController = [[Step_06_ViewController alloc] initWithNibName:@"Step_06_ViewController" bundle:nil];
    
    NSRange noQoute = NSMakeRange(1, _selectedWifiEntry.ssidWithQuotes.length - 2);
    NSString *wifiName = [_selectedWifiEntry.ssidWithQuotes substringWithRange:noQoute];
    
    [[NSUserDefaults standardUserDefaults] setObject:wifiName forKey:HOST_SSID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    step06ViewController.isOtherNetwork = [wifiName isEqualToString:@"Other Network"];
    step06ViewController.ssid = wifiName;
    step06ViewController.security = _selectedWifiEntry.authMode;
    
    [self.navigationController pushViewController:step06ViewController animated:NO];
}

- (void)showDialogToConfirm:(NSString *)homeWifi selectedWifi:(NSString *)selectedWifi
{
    NSString *msg = [NSString stringWithFormat:@"You have selected wifi %@ which is not the same as your Home wifi, %@. If you choose to continue, there will more steps to setup your camera. Do you want to proceed?", selectedWifi, homeWifi];
    
    UIAlertView *alertViewNotice = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];
    alertViewNotice.tag = ALERT_CONFIRM_TAG;
    [alertViewNotice show];
}

- (void)queryWifiList
{
    NSLog(@"Step_05_VC - queryWifiList. Waiting...");
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    
    NSData *router_list_raw;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fwVersion = [userDefaults stringForKey:FW_VERSION]; // 01.12.58
    
    BOOL newCmdFlag = TRUE;
    
    if ([fwVersion compare:FW_MILESTONE] >= NSOrderedSame) {
        // fw >= FW_MILESTONE
        router_list_raw = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:GET_ROUTER_LIST2
                                                                        withTimeout:2*DEFAULT_TIME_OUT];
        
        NSLog(@"%s - router_list_raw: %@", __FUNCTION__, [[NSString alloc] initWithData:router_list_raw encoding:NSUTF8StringEncoding]);
    }
    else {
        newCmdFlag = FALSE;
        router_list_raw = [[HttpCom instance].comWithDevice sendCommandAndBlock_raw:GET_ROUTER_LIST
                                                                        withTimeout:2*DEFAULT_TIME_OUT];
    }
    
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
    if ( router_list_raw ) {
        WifiListParser *routerListParser = [[WifiListParser alloc]initWithNewCmdFlag:newCmdFlag];
        
        [routerListParser parseData:router_list_raw
                       whenDoneCall:@selector(setWifiResult:)
                             target:self];
    }
    else {
        NSLog(@"GOT NULL wifi list from camera");
        [self askForRetry];
    }
}

- (void)askForRetry
{
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:LocStr(@"Fail_to_communicate_with_camera")
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:LocStr(@"Cancel")
                                            otherButtonTitles:LocStr(@"Retry"), nil];
    myAlert.tag = ALERT_RETRY_WIFI_TAG;
    [myAlert show];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step05 - dismiss dialog with button index: %d", buttonIndex] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:[NSString stringWithFormat:@"Dismiss alert: %d", alertView.tag]
                                                     withLabel:[NSString stringWithFormat:@"Alert %@", alertView.title]
                                                     withValue:nil];
    
    if (alertView.tag == ALERT_RETRY_WIFI_TAG) {
        switch(buttonIndex) {
            case 0:
            {
                //TODO: Go back to camera detection screen
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 1:
            {
                //retry ..
                [self.view addSubview:_viewProgress];
                [self.view bringSubviewToFront:_viewProgress];
                
                NSLog(@"OK button pressed");
                [self performSelectorInBackground:@selector(queryWifiList) withObject:nil];
                break;
            }
                
            default:
                break;
        }
    }
    else if(alertView.tag == ALERT_CONFIRM_TAG) {
        if (buttonIndex == 1) {
            // Continue
            [self moveToNextStep];
        }
    }
    else {
        NSLog(@"Step_05_VC - alertDismiss: %d", alertView.tag);
    }
}

#pragma mark - WifiListParse delegate

- (void)setWifiResult:(NSArray *)wifiList
{
    NSLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count);

    // hide progressView
    [_viewProgress removeFromSuperview];

    WifiEntry *entry;
    for (int i = 0; i < wifiList.count; i++) {
        entry = [wifiList objectAtIndex:i];
        NSLog(@"entry: %d, ssid_w_quote: %@, bssid: %@, auth_mode: %@, quality: %@", i, entry.ssidWithQuotes, entry.bssid, entry.authMode, entry.quality);
    }
    
    self.listOfWifi = [NSMutableArray arrayWithArray:wifiList];
    
    [_listOfWifi addObject:_otherWiFi];
    [self filterCameraList];
    [_tableView reloadData];
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
            
            WifiEntry *entry = _listOfWifi[indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:[NSString stringWithFormat:@"Step05 - table view select row: %d in section: %d", indexPath.row, indexPath.section] withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Select Wifi entry"
                                                     withLabel:@"Row"
                                                     withValue:[NSNumber numberWithInteger:indexPath.row]];
    if (indexPath.section == 0) {
        _btnContinue.enabled = YES;
        self.selectedWifiEntry = (WifiEntry *)_listOfWifi[indexPath.row];
    }
    else {
        [self.view addSubview:_viewProgress];
        [self.view bringSubviewToFront:_viewProgress];
        [self performSelectorInBackground:@selector(queryWifiList) withObject:nil];
    }
}

@end
