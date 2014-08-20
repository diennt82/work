//
//  Step_02_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_02_ViewController.h"
#import "Step_03_ViewController.h"
#import "UIBarButtonItem+Custom.h"

#import "MBPNavController.h"
#import "CreateBLEConnection_VController.h"
#import "BLEConnectionManager.h"
//#import "KISSMetricsAPI.h"
#import "Focus73TableViewController.h"
#import "define.h"
#import "UIView+Custom.h"

#define GAI_CATEGORY    @"Step 02 view"

@interface Step_02_ViewController () <Step_03Delegate>

@property (retain, nonatomic) IBOutlet UIButton *btnContinue;
@property (retain, nonatomic) IBOutlet UIView *viewInstructionFocus73;

@end

@implementation Step_02_ViewController

@synthesize delegate;


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
    [self xibDefaultLocalization];

    [self removeNavigationBarBottomLine];
    self.navigationItem.hidesBackButton = TRUE;
    
    UIImage *hubbleLogo = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogo
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogo]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnContinue setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    
    NSLog(@"%s Camera model:%d", __FUNCTION__, _cameraType);
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:585];
    imageView.animationImages = @[[UIImage imageNamed:@"setup_camera_led1"],
                                  [UIImage imageNamed:@"setup_camera_led2"]];
    imageView.animationDuration = 2.f;
    imageView.animationRepeatCount = 0;
    
    [imageView startAnimating];
    
    if (_cameraType == BLUETOOTH_SETUP || _cameraType == SETUP_CAMERA_FOCUS73)
    {
        NSLog(@"%s- isOnBLE: %d", __FUNCTION__, [BLEConnectionManager getInstanceBLE].isOnBLE);
    }
}

- (void)xibDefaultLocalization
{
    [[self.view viewWithTag:10] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step02_label_before", nil, [NSBundle mainBundle], @"Before you start:", nil)];
    [[self.view viewWithTag:11] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step02_label_follow", nil, [NSBundle mainBundle], @"Follow the 3 simple steps", nil)];
    [[self.view viewWithTag:12] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step02_label_plugin", nil, [NSBundle mainBundle], @"Plugin and switch camera on", nil)];
    [[self.view viewWithTag:13] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step02_label_waitfor", nil, [NSBundle mainBundle], @"Wait for one minute for it to warm up", nil)];
    [[self.view viewWithTag:14] setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step02_label_whentheLED", nil, [NSBundle mainBundle], @"When the LED starts to blink press continue", nil)];
    
    [self.btnContinue setLocalizationText:NSLocalizedStringWithDefaultValue(@"xib_step02_button_continue", nil, [NSBundle mainBundle], @"Continue", nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    
    self.trackedViewName = GAI_CATEGORY;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)removeNavigationBarBottomLine
{
    for (UIView *parentView in self.navigationController.navigationBar.subviews)
    {
        for (UIView *childView in parentView.subviews)
        {
            if ([childView isKindOfClass:[UIImageView class]] &&
                childView.bounds.size.height <= 1)
            {
                [childView removeFromSuperview];
                return;
            }
        }
    }
}

#pragma mark - 
#pragma mark Actions

- (void)hubbleItemAction: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate sendStatus:SHOW_CAMERA_LIST2];
    }];
}

- (IBAction)btnContinueTouchUpInsideAction:(id)sender
{
    //[[KISSMetricsAPI sharedAPI] recordEvent:@"Step02 - Touch up inside continue button" withProperties:nil];
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:GAI_CATEGORY
                                                    withAction:@"Touch up inside continue button"
                                                     withLabel:@"Continue"
                                                     withValue:[NSNumber numberWithInteger:_cameraType]];
    /**
     * 1. nil == sender: --> Forcing to setup with WIFI from somewhere in BLE flow steps.
     * 2. nil != sender: --> Using normal flow.
     */
    
    if (!sender)
    {
        [self moveToNextWifiStep];
    }
    else
    {
        if (_cameraType == BLUETOOTH_SETUP || _cameraType == SETUP_CAMERA_FOCUS73)
        {
            [self moveToNextBLEStep];
        }
        else
        {
            [self moveToNextWifiStep];
        }
    }
}
#if 0
- (IBAction)goBackToFirstScreen:(id)sender
{
    //[self.delegate sendStatus:FRONT_PAGE];
    [self.delegate sendStatus:LOGIN];
}
#endif

- (void)startMonitorCallBack:(BOOL)success;
{
    [self dismissViewControllerAnimated:NO completion:^{
        NSInteger status = SHOW_CAMERA_LIST;
        
        if (!success)
        {
            status = SHOW_CAMERA_LIST2;
        }
        
        [self.delegate sendStatus:status];
    }];
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

- (void)dealloc {
    [_btnContinue release];
    [_viewInstructionFocus73 release];
    [super dealloc];
}

#pragma mark - Step_03Delegate
- (void)goBackCameralist {
    [self hubbleItemAction:nil];
}

- (void)moveToNextWifiStep
{
    NSLog(@"Load step 3 Concurrent");
    Step_03_ViewController *step03ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        step03ViewController = [[Step_03_ViewController alloc] initWithNibName:@"Step_03_ViewController_ipad" bundle:nil];
    }
    else
    {
        step03ViewController = [[Step_03_ViewController alloc] initWithNibName:@"Step_03_ViewController" bundle:nil];
    }
    
    step03ViewController.delegate = self;
    [self.navigationController pushViewController:step03ViewController animated:NO];
    
    [step03ViewController release];
}

- (void)moveToNextBLEStep
{
    NSLog(@"Load step Create BLE Connection");
    //Load the next xib
    CreateBLEConnection_VController *step03ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        step03ViewController = [[CreateBLEConnection_VController alloc]
                                initWithNibName:@"CreateBLEConnection_VController_iPad"
                                bundle:nil];
    }
    else
    {
        step03ViewController = [[CreateBLEConnection_VController alloc] initWithNibName:@"CreateBLEConnection_VController"
                                                                                 bundle:nil];
    }
    
    step03ViewController.cameraType = _cameraType;
    [self.navigationController pushViewController:step03ViewController animated:NO];
    
    [step03ViewController release];
}

@end

















