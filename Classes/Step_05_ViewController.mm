//
//  Step_05_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/25/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_05_ViewController.h"
#import "Step05Cell.h"

@interface Step_05_ViewController () <UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UITableViewCell *cellOtherNetwork;

@property (retain, nonatomic) WifiEntry *selectedWifiEntry;
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
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
#if 1
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    [self.view viewWithTag:501].transform = transform;
    
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
#else
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Configure_Camera",nil, [NSBundle mainBundle],
                                                                  @"Configure Camera" , nil);
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
#endif
    
    if (listOfWifi == nil )
    {
        NSLog(@"EMPTY LIST WIFI"); 
    }
    
    //Create an entry for "Other.."
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

-(void) viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
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
    //NSString * homeSsid = (NSString *) [userDefaults objectForKey:HOME_SSID];
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
    
    step06ViewController.isOtherNetwork = [wifiName isEqualToString:@"Other Network"];
    
    step06ViewController.ssid = wifiName;
    step06ViewController.security = _selectedWifiEntry.auth_mode;
    
    [self.navigationController pushViewController:step06ViewController animated:NO];
    
    [step06ViewController release];
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
    if (buttonIndex == 1) // Continue
    {
        [self moveToNextStep];
    }
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listOfWifi.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *sectionName = @"Select the wifi connection that your camera can use";
//
//    return sectionName;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#if 1
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
    
#else
    
#if 1
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    WifiEntry *entry = [listOfWifi objectAtIndex:indexPath.row];
    cell.textLabel.text = entry.ssid_w_quote;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
#else
    int tag = tableView.tag;
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier = @"Cell";
    if (tag == 11)
    {
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                [[NSBundle mainBundle] loadNibNamed:@"Step_05_tableViewCell_ipad" owner:self options:nil];
            }
            else
            {
                [[NSBundle mainBundle] loadNibNamed:@"Step_05_tableViewCell" owner:self options:nil];
            }
            cell = self.cellView;
            self.cellView = nil; 
        }
        [cell setBackgroundColor:[UIColor whiteColor]];
        // Set up the cell...
        WifiEntry *entry = [listOfWifi objectAtIndex:indexPath.row];
        
        UITextField * ssid = (UITextField *)[cell viewWithTag:200];
        ssid.text = entry.ssid_w_quote;
        ssid.backgroundColor = [UIColor clearColor];
        
        //NSLog(@"table cell : %f %f ", tableView.frame.size.width, tableView.frame.size.width);

        ssid.frame = CGRectMake(0, 0, tableView.frame.size.width-20, 44);
        
         
    }
    
    
    return cell;
#endif
#endif
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
#if 1
    self.btnContinue.enabled = YES;
    self.selectedWifiEntry = (WifiEntry *)[listOfWifi objectAtIndex:indexPath.row];
#else
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];

     int tag = tableView.tag; 
    if (tag == 11)
    {
        int idx=indexPath.row;

        WifiEntry *entry = [listOfWifi objectAtIndex:idx];

        //load step 06
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
        

        
        
        
        NSRange noQoute = NSMakeRange(1, [entry.ssid_w_quote length]-2);
        if ([[entry.ssid_w_quote substringWithRange:noQoute] isEqualToString:@"Other Network"])
        {
            step06ViewController.isOtherNetwork = TRUE;
        }
        else
        {
            step06ViewController.isOtherNetwork = FALSE;
        }
        step06ViewController.ssid = [entry.ssid_w_quote substringWithRange:noQoute];
        step06ViewController.security = entry.auth_mode;

        [self.navigationController pushViewController:step06ViewController animated:NO];

        [step06ViewController release];

    }
#endif
}
#pragma mark -

-(void) handleButtonPressed:(id) sender
{
    
}

@end
