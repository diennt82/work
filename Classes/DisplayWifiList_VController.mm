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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
}

-(void) filterCameraList
{
    NSMutableArray * wifiList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [listOfWifi count]; i++)
    {
        WifiEntry * wifi = [listOfWifi objectAtIndex:i];
        //        NSLog(@"SSID Wifi -------------------->%@", wifi.ssid_w_quote);
        if (![wifi.ssid_w_quote hasPrefix:@"\"Camera-"] && ![wifi.ssid_w_quote isEqualToString:@"\"\""])
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
        return [listOfWifi count];
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
    WifiEntry *entry = [listOfWifi objectAtIndex:indexPath.row];
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
        
        WifiEntry *entry = [listOfWifi objectAtIndex:idx];
        
        //load step 06
        NSLog(@"Load step 6: Input network info");
        //Load the next xib
        NetworkInfoToCamera_VController *step06ViewController = nil;
        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            
//            step06ViewController = [[NetworkInfoToCamera_VController alloc]
//                                    initWithNibName:@"NetworkInfoToCamera_VController_iPad" bundle:nil];
//            
//        }
//        else
        {
            
            step06ViewController = [[NetworkInfoToCamera_VController alloc]
                                    initWithNibName:@"NetworkInfoToCamera_VController" bundle:nil];
            
            
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
    
}
#pragma mark -

-(void) handleButtonPressed:(id) sender
{
    
}

@end