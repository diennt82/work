//
//  AlertSettingViewController.m
//  MBP_ios
//
//  Created by NxComm on 10/1/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "AlertSettingViewController.h"

@interface AlertSettingViewController ()

@end

@implementation AlertSettingViewController


@synthesize  camera;
@synthesize soundCellView, tempHiCellView,  tempLoCellView;



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
    
    NSLog(@" viewdidload camera: %@",camera.name);
    
    [f_title  setText:camera.name];
    
    [self.view addSubview:progressView];
    [self.view bringSubviewToFront:progressView];
    
    progressView.hidden = NO;
    
    // Do any additional setup after loading the view from its nib.
    
    [self performSelector:@selector(query_disabled_alert_list:) withObject:self.camera afterDelay:0.1];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillDisappear:(BOOL)animated {
	NSArray *viewControllers = self.navigationController.viewControllers;
	if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self)
    {
        
    }
    else if ([viewControllers indexOfObject:self] == NSNotFound)
    {
		// View is disappearing because it was popped from the stack
		NSLog(@"View controller was popped --- ");
        
        [self.navigationController setNavigationBarHidden:YES];
        
	}
}



-(void) viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO];
	[self checkOrientation];
}


-(void) checkOrientation
{
    
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
	[self adjustViewsForOrientation:infOrientation];
    
    
    
}
//// DEPRECATED from IOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	return   ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
              (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

//////////////// IOS6 replacement

-(BOOL) shouldAutorotate
{

  	return YES;
}

/////////////

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
	[self adjustViewsForOrientation:toInterfaceOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    
    
    BOOL shouldShowProgress = progressView.hidden;
    NSString * f_titleText = f_title.text; 
    
    
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"AlertSettingViewController_land_ipad"
                                          owner:self
                                        options:nil];

        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"AlertSettingViewController_land"
                                          owner:self
                                        options:nil];

            
            
        }

       

        
        
    }
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"AlertSettingViewController_ipad"
                                          owner:self
                                        options:nil];
            

            
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"AlertSettingViewController"
                                          owner:self
                                        options:nil];
            

            
        }
                
	}
    
    
    
    
    f_title.text =f_titleText;
    progressView.hidden = shouldShowProgress;
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

    [alertTable reloadData];
}

#pragma mark -
#pragma mark Table view delegates & datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UISwitch * alertSw;
    switch (indexPath.row) {
        case 0:
            alertSw = (UISwitch *) [soundCellView viewWithTag:1];
            [alertSw setOn:camera.soundAlertEnabled];
            
            return soundCellView;
            break;
        case 1:
            alertSw = (UISwitch *) [tempHiCellView viewWithTag:1];
            [alertSw setOn:camera.tempHiAlertEnabled];
            
            return tempHiCellView;
            break;
        case 2:
            alertSw = (UISwitch *) [tempLoCellView viewWithTag:1];
            [alertSw setOn:camera.tempLoAlertEnabled];
            
            return tempLoCellView;
            break;
        default:
            break;
    }
    NSLog(@"Index is:%d", indexPath.row);
    
    return nil ;
    
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]
                             animated:NO];
    
    
    
}

#pragma mark -

-(IBAction)donePressed:(id)sender
{
    //[self dismissModalViewControllerAnimated:NO	];
    [self.navigationController popViewControllerAnimated:NO];
    
}

-(IBAction)soundAlertChanged   :(id)sender
{
    UISwitch * alertSw = (UISwitch *) sender;
    if (camera.soundAlertEnabled  ==  alertSw.isOn )
    {
        
    }
    else
    {
        
        progressView.hidden = NO;
        [self.view bringSubviewToFront:progressView];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                       selector:@selector(updateSoundAlert:)
                                       userInfo:alertSw
                                        repeats:NO];
        
    }
}

-(void) updateSoundAlert:(NSTimer *) exp
{
    UISwitch * alertSw = (UISwitch *) exp.userInfo;
    NSLog(@"update sound alert");
    

    camera.soundAlertEnabled  =  alertSw.isOn;
    progressView.hidden = YES;
    
}

-(IBAction)tempHiAlertChanged   :(id)sender
{
    UISwitch * alertSw = (UISwitch *) sender;
    if (camera.tempHiAlertEnabled ==  alertSw.isOn )
    {
        
    }
    else
    {
        
        progressView.hidden = NO;
        [[progressView superview] bringSubviewToFront:progressView];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                       selector:@selector(updateTempHiAlert:)
                                       userInfo:alertSw
                                        repeats:NO];
        
        
        
    }
}

-(void) updateTempHiAlert:(NSTimer *) exp
{
    
    UISwitch * alertSw = (UISwitch *) exp.userInfo;
    
    NSLog(@"update temmp hi alert");

    
    camera.tempHiAlertEnabled  =  alertSw.isOn;
    
    progressView.hidden = YES;
    
}
-(IBAction)tempLoAlertChanged   :(id)sender
{
    UISwitch * alertSw = (UISwitch *) sender;
    if (camera.tempLoAlertEnabled  ==  alertSw.isOn )
    {
        
    }
    else
    {
        
        progressView.hidden = NO;
        [[progressView superview] bringSubviewToFront:progressView];
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                       selector:@selector(updateTempLoAlert:)
                                       userInfo:alertSw
                                        repeats:NO];
        
        
        
    }
}
-(void) updateTempLoAlert:(NSTimer *) exp
{
    
    UISwitch * alertSw = (UISwitch *) exp.userInfo;
    
    
    camera.tempLoAlertEnabled  =  alertSw.isOn;    progressView.hidden = YES;
    
}

#pragma  mark -
#pragma  mark query disabled alerts

-(void) query_disabled_alert_list:(CamProfile *) cp
{

	
    //All enabled - default
    cp.soundAlertEnabled = TRUE;
    cp.tempHiAlertEnabled = TRUE;
    cp.tempLoAlertEnabled = TRUE;
    
    [alertTable reloadData];
    progressView.hidden = YES;
    
    
    
}



#pragma  mark -

@end
