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

@interface Focus73TableViewController () <BonjourDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell *cellSearchAgain;
@property (nonatomic, retain) NSMutableArray *arrayFocus73;
@property (nonatomic, retain) NSThread *threadBonjour;

@end

@implementation Focus73TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
}

- (void)startScanningWithBonjour
{
    self.threadBonjour = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(scanWithBonjour)
                                                   object:nil];
    [_threadBonjour start];
}

-(void) scanWithBonjour
{
    @autoreleasepool
    {
        // When use autoreleseapool, no need to call autorelease.
        Bonjour *bonjour = [[Bonjour alloc] initSetupWith:[NSMutableArray arrayWithObject:self.selectedChannel.profile]];
        [bonjour setDelegate:self];
        
        [bonjour startScanLocalWiFi];
        
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        
        while (bonjour.isSearching)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        
        self.bonjourList = [NSMutableArray arrayWithArray:bonjour.cameraList];
    }
    
    [NSThread exit];
}

- (void)dealloc
{
    [_arrayFocus73 release];
    [_cellSearchAgain release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return section==0?_arrayFocus73.count:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"BLEConnectionCell";
        BLEConnectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BLEConnectionCell" owner:nil options:nil];
        
        for (id curObj in objects)
        {
            if ([curObj isKindOfClass:[BLEConnectionCell class]])
            {
                cell = (BLEConnectionCell *)curObj;
                break;
            }
        }
        
        //cell.lblName.text = _arrayFocus73[indexPath.row];
        
        return cell;
    }
    else
    {
        return _cellSearchAgain;
    }
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
