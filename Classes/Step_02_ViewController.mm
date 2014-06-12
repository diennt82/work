//
//  Step_02_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 eBuyNow eCommerce Limited. All rights reserved.
//

#import "Step_02_ViewController.h"
#import "Step_03_ViewController.h"
#import "UIBarButtonItem+Custom.h"
#import "PAIRInstructionViewController.h"
#import "MBPNavController.h"
#import "CreateBLEConnection_VController.h"
#import "BLEConnectionManager.h"
#import "KISSMetricsAPI.h"

#define GAI_CATEGORY @"Step 02 view"

@interface Step_02_ViewController ()

@property (nonatomic, retain) IBOutlet UIButton *btnContinue;

@end

@implementation Step_02_ViewController

#pragma mark -  UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self removeNavigationBarBottomLine];
    self.navigationItem.hidesBackButton = TRUE;
    
    UIImage *hubbleLogo = [UIImage imageNamed:@"hubble_logo"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogo
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogo]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:585];
    imageView.animationImages = @[[UIImage imageNamed:@"setup_camera_led1"],
                                  [UIImage imageNamed:@"setup_camera_led2"]];
    imageView.animationDuration = 1.f;
    imageView.animationRepeatCount = 0;
    
    [imageView startAnimating];
    
    if (_cameraType == BLUETOOTH_SETUP) {
        NSLog(@"Step_02_VC - viewDidLoad: - isOnBLE: %d", [BLEConnectionManager getInstanceBLE].isOnBLE);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.trackedViewName = GAI_CATEGORY;
}

- (void)removeNavigationBarBottomLine
{
    for (UIView *parentView in self.navigationController.navigationBar.subviews) {
        for (UIView *childView in parentView.subviews) {
            if ([childView isKindOfClass:[UIImageView class]] && childView.bounds.size.height <= 1) {
                [childView removeFromSuperview];
                return;
            }
        }
    }
}

- (void)presentModallyOn:(UIViewController *)parent
{
    //setup nav controller
    MBPNavController *navController = [[[MBPNavController alloc] initWithRootViewController:self] autorelease];
    
    // Create a navigation controller with us as its root.
    assert(navController != nil);
    
    // Present the navigation controller on the specified parent
    [parent presentViewController:navController animated:NO completion:nil];
}

#pragma mark - Actions

- (void)hubbleItemAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate sendStatus:AFTER_DEL_RELOGIN];
    }];
}

- (IBAction)btnContinueTouchUpInsideAction:(id)sender
{
    [[KISSMetricsAPI sharedAPI] recordEvent:@"Step02 - Touch up inside continue button" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Touch up inside continue button"
                                                     withLabel:@"Continue"
                                                     withValue:[NSNumber numberWithInteger:_cameraType]];
    if (_cameraType == BLUETOOTH_SETUP) {
        NSLog(@"Load step Create BLE Connection");
        CreateBLEConnection_VController *step03ViewController = [[CreateBLEConnection_VController alloc] initWithNibName:@"CreateBLEConnection_VController" bundle:nil];
        [self.navigationController pushViewController:step03ViewController animated:NO];
        [step03ViewController release];
    }
    else {
        NSLog(@"Load step 3 Concurrent");
        Step_03_ViewController *step03ViewController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            step03ViewController = [[Step_03_ViewController alloc] initWithNibName:@"Step_03_ViewController_ipad" bundle:nil];
        }
        else {
            step03ViewController = [[Step_03_ViewController alloc] initWithNibName:@"Step_03_ViewController" bundle:nil];
        }
        
        [self.navigationController pushViewController:step03ViewController animated:YES];
        [step03ViewController release];
    }
}

- (IBAction)goBackToFirstScreen:(id)sender
{
    //[self.delegate sendStatus:FRONT_PAGE];
    [_delegate sendStatus:LOGIN];
}

-(void)startMonitorCallBack
{
    [self dismissViewControllerAnimated:NO completion:^{
        // New flow: Show Camera list after Add a new Camera
        [_delegate sendStatus:SHOW_CAMERA_LIST];
    }];
}

- (IBAction)handleButtonPress:(id)sender
{
    //int tag = ((UIButton*)sender).tag;
    
    //if (tag == CONTINUE_BTN_TAG)
    {
        
#if 1
        NSLog(@"Load step 3");
        //Load the next xib
        Step_03_ViewController *step03ViewController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            step03ViewController = [[Step_03_ViewController alloc] initWithNibName:@"Step_03_ViewController_ipad" bundle:nil];
            
        }
        else {
            step03ViewController = [[Step_03_ViewController alloc] initWithNibName:@"Step_03_ViewController" bundle:nil];
            
        }
        
        [self.navigationController pushViewController:step03ViewController animated:NO];
        [step03ViewController release];
        
#else // DBG - TEST view layout ..
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:@"11:22:33:44:55:66" forKey:@"CameraMacWithQuote"];
        [userDefaults synchronize];
       
        //Load step 10
        NSLog(@"Load Step 10");
        //Load the next xib
        Step_10_ViewController *step10ViewController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            step10ViewController = [[Step_10_ViewController alloc] initWithNibName:@"Step_10_ViewController_ipad" bundle:nil];
        }
        else {
            step10ViewController = [[Step_10_ViewController alloc] initWithNibName:@"Step_10_ViewController" bundle:nil];
        }
        
        [self.navigationController pushViewController:step10ViewController animated:NO];
        [step10ViewController release];
#endif
    }
}

#pragma  mark -

- (UIImage *)imageWithNameString:(NSString *)nameString scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
    [[UIImage imageNamed:nameString] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return newImage;
}

- (void)dealloc
{
    [_btnContinue release];
    [super dealloc];
}

@end
