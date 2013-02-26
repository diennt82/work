//
//  Step_11_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Step_11_ViewController.h"

@interface Step_11_ViewController ()

@end

@implementation Step_11_ViewController

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
    self.navigationItem.hidesBackButton = YES;
    
	// Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedStringWithDefaultValue( @"Add_Camera_Failed",nil, [NSBundle mainBundle],
                                                                  @"Add Camera Failed" , nil);

    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Rotating
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //TODO
        }
        else
        {
            // Add cameras fail in landscape mode
            
            self.navigationItem.title =
            NSLocalizedStringWithDefaultValue( @"Add_Camera_Failed",
                                              nil,
                                              [NSBundle mainBundle],
                                              @"Add Camera Failed" , nil);
            
            [[NSBundle mainBundle] loadNibNamed:@"Step_11_ViewController_land" owner:self options:nil];
            
            UIScrollView *tempScrollView=(UIScrollView *) [self.view viewWithTag:1];
            [tempScrollView setContentSize:CGSizeMake(380, 400)];

            
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //TODO
        }
        else
        {
            
            self.navigationItem.title =
            NSLocalizedStringWithDefaultValue( @"Add_Camera_Failed",
                                              nil,
                                              [NSBundle mainBundle],
                                              @"Add Camera Failed" ,
                                              nil);
            
            [[NSBundle mainBundle] loadNibNamed:@"Step_11_ViewController" owner:self options:nil];
            
            UIScrollView *tempScrollView=(UIScrollView *) [self.view viewWithTag:1];
            [tempScrollView setContentSize:CGSizeMake(320, 450)];
            


            
        }
    }
}

#pragma  mark -
#pragma mark button handlers

-(IBAction)tryAddCameraAgain:(id)sender
{
    
    //Go back to the beginning
    
    // Disable Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled=  NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    
}



@end
