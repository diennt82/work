//
//  Account_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/3/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Account_ViewController.h"

@interface Account_ViewController ()

@end

@implementation Account_ViewController

@synthesize  mdelegate;
@synthesize  mtopbar;

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
    [mtopbar release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self.navigationController setNavigationBarHidden:YES];
    
    //Build ToolBar manually
    
    
    mtopbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    mtopbar.barStyle = UIBarStyleBlackOpaque;
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    // create a standard reload button
#if 0
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                     target:nil
                                     action:nil];
    reloadButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:reloadButton];
    [reloadButton release];
    
  #endif  
    // create a spacer between the buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil
                               action:nil];
    [buttons addObject:spacer];
    [spacer release];

    
    //Label
    UIBarButtonItem *label = [[UIBarButtonItem alloc]
                              init];
    label.style = UIBarButtonItemStylePlain;
    label.title =@"Account";
    [buttons addObject:label];
    [label release];
    
    
    // create a spacer between the buttons
     spacer = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                target:nil
                                action:nil];
    [buttons addObject:spacer];
    [spacer release];
    
    
    // create a standard delete button with the trash icon
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Logout"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(userLogout)];
    
    [buttons addObject:logoutButton];
    [logoutButton release];
    
    // put the buttons in the toolbar and release them
    [mtopbar setItems:buttons animated:NO];
    [buttons release];
    
    
    
    [self.view addSubview:mtopbar];
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//can be user email or user name here --
	NSString * user_name = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
	NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUseremail"];
    
    
    UITextField * _user = (UITextField *) [userNameCell viewWithTag:1];
    _user.text = user_name;
    _user =  (UITextField *) [userEmailCell viewWithTag:1];
    _user.text = user_email;
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear --");
    	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
    
    
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(BOOL) shouldAutorotate
{
    NSLog(@"shouldAutorotate --");
    return YES ;
}

-(NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"supportedInterfaceOrientations --");
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    NSLog(@"will rotate to interface");
    
    [self adjustViewsForOrientation:toInterfaceOrientation];
}

-(void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        
        
        mtopbar.frame = CGRectMake(0, 0, 480, mtopbar.frame.size.height);
        
        accountInfo.frame = CGRectMake(0,44, 480, 268);
        
        UIImageView * bg = (UIImageView*) [self.view viewWithTag:1];
        if (bg != nil)
        {
            //transform.
            CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
            bg.transform = transform;
            bg.frame = CGRectMake(0,0, 480, 320);
        }
        
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        
        mtopbar.frame = CGRectMake(0, 0, 320, mtopbar.frame.size.height);
        accountInfo.frame = CGRectMake(0,44, 320, 268);
        UIImageView * bg = (UIImageView*) [self.view viewWithTag:1];
        if (bg != nil)
        {
            //transform.
            CGAffineTransform transform = CGAffineTransformMakeRotation(0);
            bg.transform = transform;
            bg.frame = CGRectMake(0,0, 320, 480);
        }
    }
    
    
    
}



-(void) userLogout
{
    NSLog(@"LOG OUT>>>>");
    if (mdelegate == nil)
    {
        NSLog(@"Delegate is nill");
    }
    else
    {
        
        
        accountInfo.hidden = YES;
        progress.hidden = NO; 
        
        //User logout --
        // 1 . Clear all alert
        [CameraAlert clearAllAlerts];
        //TODO: 2 . Clear offline data
        
        
        [mdelegate sendStatus:8];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


#define USERNAME_INDEX 0
#define USEREMAIL_INDEX 1
#define USERCPASS_INDEX 2



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == USERNAME_INDEX) {
        return userNameCell;
    }
    
    
    if (indexPath.row == USEREMAIL_INDEX)
    {
        return userEmailCell;
    }
    
    return nil;
    
}

@end
