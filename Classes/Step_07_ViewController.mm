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
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Security",nil, [NSBundle mainBundle],
                                                                  @"Security" , nil);

    securityTypes = [[NSArray alloc]initWithObjects:@"none", @"wep" , @"wpa",
                     nil];
    
    
    self.sec_index = -1; 
    
//    NSIndexPath * firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
//    
//    [myTable selectRowAtIndexPath:firstRow animated:NO scrollPosition:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
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
#if 0
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"Step_07_ViewController_land_ipad" owner:self options:nil];
        } else {
            [[NSBundle mainBundle] loadNibNamed:@"Step_07_ViewController_land" owner:self options:nil];
        }
    } else if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"Step_07_ViewController_ipad" owner:self options:nil];
        } else {
            [[NSBundle mainBundle] loadNibNamed:@"Step_07_ViewController" owner:self options:nil];
        }
    }
#endif
}


#pragma  mark -
#pragma mark Table View delegate & datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#if 1
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = (NSString *) [self.securityTypes objectAtIndex:indexPath.row];
    
    return cell;
#else
    int tag = tableView.tag;
    UITableViewCell *cell = nil;
    if (tag == 12)
    {
        
        static NSString *CellIdentifier = @"Cell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                [[NSBundle mainBundle] loadNibNamed:@"Step_07_tableViewCell_ipad" owner:self options:nil];
            }
            else
            {
                 [[NSBundle mainBundle] loadNibNamed:@"Step_07_tableViewCell" owner:self options:nil];
            }

            
           
            cell = self.cellView;
            self.cellView = nil; 
        }
        [cell setBackgroundColor:[UIColor whiteColor]];
        // Set up the cell... 
        
        
        UITextField * secType = (UITextField *)[cell viewWithTag:200];
        secType.text = (NSString *) [self.securityTypes objectAtIndex:indexPath.row];
        secType.backgroundColor = [UIColor clearColor];
        
    }
    
    
    return cell;
#endif
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
    
    if ([self.securityDelegate respondsToSelector:@selector(changeSecurityType:)])
    {
        [self.securityDelegate changeSecurityType:[securityTypes objectAtIndex:self.sec_index]];
    }
}



#pragma  mark -

@end
