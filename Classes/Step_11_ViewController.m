//
//  Step_11_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 2/26/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Step_11_ViewController.h"
#import "KISSMetricsAPI.h"
#import "define.h"
#import "PublicDefine.h"

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
    
    NSString *stringModel = @"";
    
    NSInteger model = [[NSUserDefaults standardUserDefaults] integerForKey:SET_UP_CAMERA];
    
    if (model == BLUETOOTH_SETUP)
    {
        stringModel = @"Mbp83";
    }
    else if(model == WIFI_SETUP)
    {
        stringModel = @"Focus66";
    }
    
    NSString *fwVersion = [[NSUserDefaults standardUserDefaults] stringForKey:FW_VERSION];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                         stringModel,   @"Camera model",
                         fwVersion,     @"FW",
                          _errorCode,   @"Error",
                         nil];
    
    [[KISSMetricsAPI sharedAPI] recordEvent:@"Add camera failed" withProperties:info];
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
    [[KISSMetricsAPI sharedAPI] recordEvent:@"Step11 - Touch up inside try again btn" withProperties:nil];
    //Go back to the beginning
    
    // Disable Keep screen on
    [UIApplication sharedApplication].idleTimerDisabled=  NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
    //NSString * msgLabel = [NSString stringWithFormat:@"Add Camera Failed with errorCode:%@", self.errorCode];
}



- (void)dealloc {
    [_btnTestCamera release];
    [super dealloc];
}
@end
