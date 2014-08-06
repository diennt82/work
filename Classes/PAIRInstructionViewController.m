//
//  PAIRInstructionViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 3/5/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "PAIRInstructionViewController.h"
#import "CreateBLEConnection_VController.h"

@interface PAIRInstructionViewController ()

@property (nonatomic, retain) IBOutlet UIButton *btnSearchCamera;

@end

@implementation PAIRInstructionViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;
    
    UIImage *hubbleLogoBack = [UIImage imageNamed:@"Hubble_back_text"];
    UIBarButtonItem *barBtnHubble = [[UIBarButtonItem alloc] initWithImage:hubbleLogoBack
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(hubbleItemAction:)];
    [barBtnHubble setTintColor:[UIColor colorWithPatternImage:hubbleLogoBack]];
    
    self.navigationItem.leftBarButtonItem = barBtnHubble;
    
    [self.btnSearchCamera setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.btnSearchCamera setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
}

#pragma mark - Actions

- (IBAction)btnSearchCameraTouchUpInsideAction:(id)sender
{
    NSLog(@"Load step Create BLE Connection");
    
    //Load the next xib
    CreateBLEConnection_VController *step03ViewController = [[CreateBLEConnection_VController alloc] initWithNibName:@"CreateBLEConnection_VController" bundle:nil];
    [self.navigationController pushViewController:step03ViewController animated:NO];
    [step03ViewController release];
}

- (void)hubbleItemAction: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [_btnSearchCamera release];
    [super dealloc];
}

@end
