//
//  Setup_04_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "EditCamera_VController.h"

@interface EditCamera_VController ()

@end

@implementation EditCamera_VController


@synthesize cameraMac, cameraName;
@synthesize alertView = _alertView;

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
	// Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Camera_Detected",nil, [NSBundle mainBundle],
                                                                  @"Camera Detected" , nil);
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    UIBarButtonItem *nextButton =
    [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringWithDefaultValue(@"Next",nil, [NSBundle mainBundle],
                                                                              @"Next", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleNextBtnTouchAction:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        NSLog(@"Cast to UI TextView");
        ((UITextView *)camName).text = self.cameraName;
        
    }
    
    
    
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        NSLog(@"Cast to UI Textfield");
        ((UITextField *)camName).text = self.cameraName;
        
    }
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    
    _alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [_alertView show];
    [self.alertView setBackgroundColor:[UIColor blackColor]];
    if(_alertView != nil) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        indicator.center = CGPointMake(_alertView.bounds.size.width/2, _alertView.bounds.size.height-45);
        [indicator startAnimating];
        [_alertView addSubview:indicator];
        [indicator release];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self adjustViewsForOrientations:interfaceOrientation];
}

- (void)handleNextBtnTouchAction: (id)sender
{
    NSString * cameraName_text = @"";
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        cameraName_text =((UITextView *)camName).text  ;
    }
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        cameraName_text =((UITextField *)camName).text;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cameraName_text forKey:@"CameraName"];
    [userDefaults synchronize];
    
    
    
    [self showScreenGetWifiList];
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
    NSString * tempName = @"";
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        
        tempName = ((UITextView *)camName).text;
        
    }
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        
        tempName = ((UITextField *)camName).text ;
        
    }
    
    
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        //        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        //        {
        //            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController_land_ipad" owner:self options:nil];
        //        }
        //        else
        //        {
        //            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController_land" owner:self options:nil];
        //
        //
        //        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        //        {
        //            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController_ipad" owner:self options:nil];
        //        }
        //        else
        //        {
        //            [[NSBundle mainBundle] loadNibNamed:@"Step_04_ViewController" owner:self options:nil];
        //        }
    }
    
    
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        
        
        ((UITextView *)camName).text  = tempName;
        
    }
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        
        ((UITextField *)camName).text = tempName ;
    }
    
    
    
}
#pragma mark -
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

-(void) dealloc
{
    
    [cameraName release];
    [cameraMac release];
    [super dealloc];
}


-(BOOL) isCameraNameValidated:(NSString *) cameraNames
{
    
    NSString * validString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890. '_-";
    
    
    
    for (int i = 0; i < cameraNames.length; i ++)
    {
        NSRange range = [validString rangeOfString:[NSString stringWithFormat:@"%c",[cameraNames characterAtIndex:i]]];
        if (range.location == NSNotFound) {
            return NO;
        }
    }
    
    
    return YES;
    
}

- (IBAction)handleButtonPress:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    
    NSString * cameraName_text = @"";
    
    if ([camName isMemberOfClass:[UITextView class]] )
    {
        
        cameraName_text =((UITextView *)camName).text  ;
        
    }
    
    if ([camName isMemberOfClass:[UITextField class]] )
    {
        
        cameraName_text =((UITextField *)camName).text;
    }
    
    
    
    if ([cameraName_text length] < 3 || [cameraName_text length] > CAMERA_NAME_MAX )
    {
        NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                             @"Invalid Camera Name", nil);
        
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg", nil, [NSBundle mainBundle],
                                                           @"Camera Name has to be between 3-15 characters", nil);
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:ok
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else if (![self isCameraNameValidated:cameraName_text])
    {       NSString * title = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name", nil, [NSBundle mainBundle],
                                                                 @"Invalid Camera Name", nil);
        
        NSString * msg = NSLocalizedStringWithDefaultValue(@"Invalid_Camera_Name_msg2", nil, [NSBundle mainBundle],
                                                           @"Camera name is invalid. Please enter [0-9],[a-Z], space, dot, hyphen, underscore & single quote only.", nil);
        
        NSString * ok = NSLocalizedStringWithDefaultValue(@"Ok",nil, [NSBundle mainBundle],
                                                          @"Ok", nil);
        
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:ok
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else if (tag == CONF_CAM_BTN_TAG)
    {
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cameraName_text forKey:@"CameraName"];
        [userDefaults synchronize];
        
        [self showScreenGetWifiList];
    }
}

- (void)showScreenGetWifiList
{
    NSLog(@"Load step 5");
    //Load the next xib
    DisplayWifiList_VController *step05ViewController = nil;
    step05ViewController =  [[DisplayWifiList_VController alloc]
                             initWithNibName:@"DisplayWifiList_VController" bundle:nil];
    [self.navigationController pushViewController:step05ViewController animated:NO];
    
    [step05ViewController release];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}

@end
