//
//  CameraNameViewController.m
//  BlinkHD_ios
//
//  Created by Developer on 12/12/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "CameraNameViewController.h"
#import "define.h"
#import <MonitorCommunication/MonitorCommunication.h>

@interface CameraNameViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (retain, nonatomic) IBOutlet UIView *viewPorgress;

@end

@implementation CameraNameViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedStringWithDefaultValue(@"name", nil, [NSBundle mainBundle], @"Name", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] integerValue] == 200)
        {
            self.parentVC.camChannel.profile.name = cameraName;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSLog(@"CameraNameVC - Change cameraname failed!");
            
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_change_camera_name", nil, [NSBundle mainBundle], @"Change Camera Name", nil)
                                       message:[responseDict objectForKey:@"message"]
                                      delegate:self
                             cancelButtonTitle:nil
                               otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
        }
    }
    else
    {
        NSLog(@"CameraNameVC - doneAction - responseDict == nil");
        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"alert_title_change_camera_name", nil, [NSBundle mainBundle], @"Change Camera Name", nil)
                                     message:@"Server Error"
                                    delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ok", nil, [NSBundle mainBundle], @"OK", nil), nil] autorelease] show];
    }
}

-(BOOL) isCamNameValidated:(NSString *) cameraNames
{
    if (cameraNames.length < MIN_LENGTH_CAMERA_NAME ||
        MAX_LENGTH_CAMERA_NAME < cameraNames.length)
    {
        return FALSE;
    }
    
    NSString * regex = @"[a-zA-Z0-9._-]+";
    NSPredicate * validatedName = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidatedName = [validatedName evaluateWithObject:cameraNames];
    
    return isValidatedName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //[textField becomeFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *nameString = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if ([self isCamNameValidated:nameString])
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    // Configure the cell...
//    
//    return cell;
    
    UITextField *nameTF = (UITextField *) [self.nameCell viewWithTag:59];
    nameTF.text = self.cameraName;
    nameTF.delegate = self;
    
    return _nameCell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

- (void)dealloc {
    [_nameCell release];
    [_viewPorgress release];
    [super dealloc];
}
@end
