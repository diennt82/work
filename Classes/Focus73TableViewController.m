//
//  Focus73TableViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 7/10/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "Focus73TableViewController.h"
#import "BLEConnectionCell.h"
#import "MBProgressHUD.h"
#import <CameraScanner/CameraScanner.h>
#import "Step_04_ViewController.h"
#import "CustomIOS7AlertView.h"
#import "HubbleProgressView.h"
#import "define.h"

@interface Focus73TableViewController () <BonjourDelegate, CustomIOS7AlertViewDelegate>

@property (retain, nonatomic) IBOutlet HubbleProgressView *progressBarHubble;
@property (nonatomic, retain) NSMutableArray *arrayFocus73;
@property (nonatomic) BOOL isScanning;
@property (retain, nonatomic) CustomIOS7AlertView *alertView;

@end

@implementation Focus73TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    [barBtnHubble release];
    
    self.progressBarHubble.frame = CGRectMake(0, 2, SCREEN_WIDTH, 2);
    [self.view addSubview:_progressBarHubble];
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [self createHubbleAlertView];
    
    self.arrayFocus73 = [NSMutableArray array];
    [self performSelectorInBackground:@selector(scanWithBonjour) withObject:nil];
    //[self startScanningWithBonjour];
    
    UIRefreshControl *aRefreshControl = [[UIRefreshControl alloc] init];
    [aRefreshControl addTarget:self
                        action:@selector(rescanBonjour)
              forControlEvents:UIControlEventValueChanged];
    self.refreshControl = aRefreshControl;
    [aRefreshControl release];
}

- (void)hubbleItemAction: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) scanWithBonjour
{
    @autoreleasepool
    {
        self.isScanning = TRUE;
        // When use autoreleseapool, no need to call autorelease.
        Bonjour *bonjour = [[Bonjour alloc] initSetupWith:nil];
        [bonjour setDelegate:self];
        
        [bonjour startScanLocalWiFi];
        
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        
        while (bonjour.isSearching)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        
        self.arrayFocus73 = [NSMutableArray arrayWithArray:bonjour.cameraList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[MBProgressHUD hideHUDForView:self.view animated:NO];
            [self customIOS7dialogButtonTouchUpInside:_alertView clickedButtonAtIndex:0];
            
            self.progressBarHubble.hidden = NO;
            [self.tableView reloadData];
            self.isScanning = FALSE;
            [self.refreshControl endRefreshing];
            
            if (_arrayFocus73.count == 1)
            {
                [self moveToNextStep:(CamProfile *)_arrayFocus73[0]];
            }
        });
        
        [bonjour release];
    }
}

- (void)rescanBonjour
{
    if (!_isScanning)
    {
        if (_arrayFocus73.count == 0)
        {
            [self.tableView reloadData];
        }
        
        self.progressBarHubble.hidden = YES;
        
        [self scanWithBonjour];
    }
}

- (void)dealloc
{
    [_arrayFocus73 release];
    [_progressBarHubble release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Hubble alert view & delegate

- (void)createHubbleAlertView
{
    // Here we need to pass a full frame
    
    if (_alertView == nil)
    {
        self.alertView = [[CustomIOS7AlertView alloc] init];
        // Add some custom content to the alert view
        [_alertView setContainerView:[self createDemoView]];
        
        // Modify the parameters
        //[alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Close1", @"Close2", @"Close3", nil]];
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 200, 21)];// autorelease];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Scanning camera...";
    [demoView addSubview:label];
    [label release];
    
    return demoView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return section==0?_arrayFocus73.count:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    CamProfile *cp = (CamProfile *)_arrayFocus73[indexPath.row];
    
    cell.textLabel.text = cp.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"BLE_camera_small"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (_arrayFocus73.count == 0 && !_isScanning)
    {
        return @"There is no Camera in current network.";
    }
    
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
   
    [self moveToNextStep:(CamProfile *)_arrayFocus73[indexPath.row]];
}

- (void)moveToNextStep:(CamProfile *)cp
{
    NSLog(@"Load step 4");
    //Load the next xib
    Step_04_ViewController *step04ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        step04ViewController = [[Step_04_ViewController alloc]
                                initWithNibName:@"Step_04_ViewController_ipad" bundle:nil];
        
    }
    else
    {
        step04ViewController = [[Step_04_ViewController alloc]
                                initWithNibName:@"Step_04_ViewController" bundle:nil];
    }
    
    step04ViewController.camProfile = cp;
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:step04ViewController animated:YES];
    [step04ViewController release];
}

#pragma  mark Bongour delete

- (void)bonjourReturnCameraListAvailable:(NSMutableArray *)cameraList
{
}

@end
