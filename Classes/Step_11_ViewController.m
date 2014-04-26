//
//  Step_11_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Step_11_ViewController.h"

@interface Step_11_ViewController ()

@property (nonatomic, retain) IBOutlet UILabel *error_code;
@property (retain, nonatomic) IBOutlet UIButton *btnTestCamera;

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

    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    [self.view viewWithTag:501].transform = transform;
    
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [self.btnTestCamera setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnTestCamera setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];


    if (_errorCode != nil)
    {
        [self.error_code setText:_errorCode];
    }
    else
    {
        self.error_code.hidden = YES;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma  mark -
#pragma mark button handlers

-(IBAction)tryAddCameraAgain:(id)sender
{
    
    //Go back to the beginning
    
    // Disable Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled=  NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
    NSString * msgLabel = [NSString stringWithFormat:@"Add Camera Failed with errorCode:%@",self.errorCode];
//    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Add Cameras"
//                                                      withAction:@"Add Camera Failed"
//                                                       withLabel:msgLabel
//                                                       withValue:nil];
}



- (void)dealloc {
    [_btnTestCamera release];
    [super dealloc];
}
@end
