//
//  Step_05_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/25/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_05_ViewController.h"

@interface Step_05_ViewController ()

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
        if (![wifi.ssid_w_quote hasPrefix:@"\"Camera-"])
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

            
            mTableView.frame = CGRectMake(mTableView.frame.origin.x,
                                          mTableView.frame.origin.y,
                                          mTableView.frame.size.width,
                                          550);
            
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_05_ViewController_land" owner:self options:nil];
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {

            mTableView.frame = CGRectMake(mTableView.frame.origin.x,
                                          mTableView.frame.origin.y,
                                          mTableView.frame.size.width,
                                          833);
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"Step_05_ViewController" owner:self options:nil];
        }
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
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
    
}
#pragma mark -

-(void) handleButtonPressed:(id) sender
{
    
}

@end
