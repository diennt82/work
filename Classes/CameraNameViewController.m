//
//  CameraNameViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/12/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import "CameraNameViewController.h"
#import "define.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface CameraNameViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UITableViewCell *nameCell;
@property (nonatomic, retain) IBOutlet UIView *viewPorgress;

@end

@implementation CameraNameViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Name";
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                       target:self
                                                                                       action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    UITextField *nameTF = (UITextField *) [self.nameCell viewWithTag:59];
    [nameTF becomeFirstResponder];
    nameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)doneAction: (id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.hidesBackButton = YES;
    [self.view addSubview:_viewPorgress];
    [self.view bringSubviewToFront:_viewPorgress];
    NSString *cameraName = ((UITextField *)[self.nameCell viewWithTag:59]).text;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults stringForKey:@"PortalApiKey"];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    NSDictionary *responseDict = [jsonComm updateDeviceBasicInfoBlockedWithRegistrationId:self.parentVC.camChannel.profile.registrationID
                                                                               deviceName:cameraName
                                                                                 timeZone:nil
                                                                                     mode:nil
                                                                          firmwareVersion:nil
                                                                                andApiKey:apiKey];
    if ( responseDict ) {
        if ([responseDict[@"status"] integerValue] == 200) {
            _parentVC.camChannel.profile.name = cameraName;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [[[[UIAlertView alloc] initWithTitle:@"Change Camera Name"
                                       message:[responseDict objectForKey:@"message"]
                                      delegate:self
                             cancelButtonTitle:nil
                               otherButtonTitles:@"OK", nil] autorelease] show];
        }
    }
    else {
        [[[[UIAlertView alloc] initWithTitle:@"Change Camera Name"
                                     message:@"Server Error"
                                    delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil] autorelease] show];
    }
}

- (BOOL)isCamNameValidated:(NSString *)cameraNames
{
    if (cameraNames.length < MIN_LENGTH_CAMERA_NAME || MAX_LENGTH_CAMERA_NAME < cameraNames.length) {
        return NO;
    }
    
    NSString * regex = @"[a-zA-Z0-9._-]+";
    NSPredicate * validatedName = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidatedName = [validatedName evaluateWithObject:cameraNames];
    
    return isValidatedName;
}

#pragma mark - Alert dialog delegat

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.navigationItem.hidesBackButton = NO;
    [_viewPorgress removeFromSuperview];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *nameString = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if ([self isCamNameValidated:nameString]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextField *nameTF = (UITextField *)[_nameCell viewWithTag:59];
    nameTF.text = _cameraName;
    nameTF.delegate = self;
    
    return _nameCell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)dealloc
{
    [_nameCell release];
    [_viewPorgress release];
    [super dealloc];
}

@end
