//
//  BMMenuViewController.m
//  BlinkHD_ios
//
//  Created by NxComm on 12/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "BMMenuViewController.h"
#import "H264PlayerViewController.h"
#import "MTStackViewController.h"
#import "MyFrontViewController.h"

static NSString *const MTTableViewCellIdentifier = @"MTTableViewCell";

@interface BMMenuViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_datasource;
    BOOL _didSetInitialViewController;
}
@end

@implementation BMMenuViewController

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
    
    self.tableViewMenu.delegate = self;
    self.tableViewMenu.dataSource = self;
    [self.tableViewMenu registerClass:[UITableViewCell class] forCellReuseIdentifier:MTTableViewCellIdentifier];
    
    CGRect frame = self.navigationController.navigationBar.frame;
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!_didSetInitialViewController)
    {
        [self setInitialViewController];
        _didSetInitialViewController = YES;
    }
}

- (void)setInitialViewController
{
    [self tableView:self.tableViewMenu didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableViewMenu release];
    [_firstViewController release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MTTableViewCellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *textCell;
    switch (indexPath.row) {
        case 0:
            textCell = @"Camera View";
            break;
        case 1:
            textCell = @"Logout";
            break;
        case 2:
            textCell = @"Settings";
            break;
        case 3:
            textCell = @"Cameras";
            break;
            
        default:
            break;
    }
    
    cell.textLabel.text = textCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"self.stackViewController.rightViewController.title = %@", self.stackViewController.rightViewController.title);
    
    if (indexPath.row == 3)
    {
        [(H264PlayerViewController *)self.firstViewController stopStream];
        [[self stackViewController] hideRightViewController];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
    else
    {
        UINavigationController *navigationController = (UINavigationController *)[[self stackViewController] contentViewController];
        [navigationController setViewControllers:@[[self contentViewcontrollerForIndexPath:indexPath]]];
        
        [[self stackViewController] hideRightViewController];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (UIViewController *)contentViewcontrollerForIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = [UIViewController new];
    if (indexPath.row == 0) {
        viewController = self.firstViewController;
        //viewController = [[MyFrontViewController alloc] init];
    }
    else{
        [[viewController view] setBackgroundColor:_datasource[[indexPath row]]];
        [[viewController navigationItem] setTitle:[NSString stringWithFormat:@"View Controller %d", [indexPath row]]];
    }
    
    UIBarButtonItem *revealIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:[self stackViewController]
                                                                  action:@selector(toggleLeftViewController)];
    viewController.navigationItem.leftBarButtonItem = revealIcon;
    
    return viewController;
}

@end
