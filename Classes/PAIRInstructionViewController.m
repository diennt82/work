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

@property (nonatomic, weak) IBOutlet UIButton *searchCameraButton;
@property (nonatomic, weak) IBOutlet UILabel *pairLabel;
@property (nonatomic, weak) IBOutlet UILabel *detectingCameraLabel;
@property (nonatomic, weak) IBOutlet UILabel *instructionLabel;

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
    
    [self.searchCameraButton setBackgroundImage:[UIImage imageNamed:@"green_btn"] forState:UIControlStateNormal];
    [self.searchCameraButton setBackgroundImage:[UIImage imageNamed:@"green_btn_pressed"] forState:UIControlEventTouchDown];
    
    _pairLabel.text = LocStr(@"Pair");
    _detectingCameraLabel.text = LocStr(@"Detecting the Camera");
    _instructionLabel.text = LocStr(@"Press and hold the button marked 'PAIR' for 3 seconds and then click the Search button (below) to continue");
    [_searchCameraButton setTitle:LocStr(@"Search for Camera") forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)btnSearchCameraTouchUpInsideAction:(id)sender
{
    DLog(@"Load step Create BLE Connection");
    CreateBLEConnection_VController *step03ViewController = [[CreateBLEConnection_VController alloc] initWithNibName:@"CreateBLEConnection_VController" bundle:nil];
    [self.navigationController pushViewController:step03ViewController animated:YES];
}

- (void)hubbleItemAction: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
