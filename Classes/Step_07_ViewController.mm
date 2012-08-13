//
//  Step_07_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/6/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_07_ViewController.h"

@interface Step_07_ViewController ()

@end

@implementation Step_07_ViewController
@synthesize  cellView;
@synthesize securityTypes;
@synthesize  step06; 
@synthesize  sec_index; 

-(void)dealloc
{
    [cellView release];
    [securityTypes release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Security"; 

    securityTypes = [[NSArray alloc]initWithObjects:@"none", @"wep", @"wap", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma  mark -
#pragma mark Table View delegate & datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int tag = tableView.tag;
    UITableViewCell *cell = nil;
    if (tag == 12)
    {
        
        static NSString *CellIdentifier = @"Cell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"Step_07_tableViewCell" owner:self options:nil];
            cell = self.cellView;
            self.cellView = nil; 
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        // Set up the cell... 
        
        
        UITextField * secType = (UITextField *)[cell viewWithTag:200];
        secType.text = (NSString *) [self.securityTypes objectAtIndex:indexPath.row];
        secType.backgroundColor = [UIColor clearColor];
        
    }
    
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tag = tableView.tag;
    
    if( tag == 12)
    {
        return [securityTypes count];
    }
    
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int tag = tableView.tag;
    if( tag == 12)
    {
        return 1;
    }
    return 0; 
}



- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] 
                             animated:NO];
    if (self.sec_index == indexPath.row) {
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.sec_index inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.sec_index = indexPath.row;
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    step06.security = [securityTypes objectAtIndex:self.sec_index];
}



#pragma  mark -

@end
