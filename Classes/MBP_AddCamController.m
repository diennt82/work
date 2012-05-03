//
//  MBP_AddCamController.m
//  MBP_ios
//
//  Created by NxComm on 5/2/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_AddCamController.h"


@implementation MBP_AddCamController

@synthesize step_1View, step_2View;
@synthesize device_mac; 
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) d
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		delegate = d;
    }
    return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/**/
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
		 (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark Handle button press
- (IBAction) handleButtonPressed:(id) sender
{
	int sender_tag = ((UIButton *) sender).tag;
	
	switch (sender_tag) {
		case STEP_1_NEXT_BTN:
			
		{

			BMS_Communication * bms_comm; 
						
			NSString * mac = [self.device_mac text];
			
			NSLog(@"mac: %@", mac);
			
			
			bms_comm = [[BMS_Communication alloc] initWithObject:self
														Selector:@selector(addCamSuccessWithResponse:) 
													FailSelector:@selector(addCamFailedWithError:) 
													   ServerErr:@selector(addCamFailedServerUnreachable)];
			
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			NSString * user_email = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
			NSString * user_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
			
			
			[bms_comm BMS_addCamWithUser:user_email 
								 AndPass:user_pass 
								 macAddr:mac 
								 camName:@""];
			
			
			break;
		}
		case STEP_2_NEXT_BTN:
			break;
		default:
			break;
	}
	
}


#pragma mark -
#pragma mark  Callbacks
- (void) addCamSuccessWithResponse:(NSData*) responseData
{
	
	NSLog(@"add success response: " );
	MBP_DeviceConfigureViewController * setupController;
	setupController = [[MBP_DeviceConfigureViewController alloc] initWithNibName:@"MBP_DeviceConfigureViewController"
																		  bundle:nil
																	withDelegate:nil ];
	
	[self presentModalViewController:setupController animated:YES];
	
	//hide step 1 scroll view
	self.step_1View.hidden = YES;
	
	
}

- (void) addCamFailedWithError:(NSHTTPURLResponse*) error_response
{
	NSLog(@"Loging failed with error code:%d", [error_response statusCode]);
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Login Error"
						  message:[NSString stringWithFormat:@"Server error code: %d", [error_response statusCode]] 
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	return;
	
}
- (void) addCamFailedServerUnreachable
{
	NSLog(@"Loging failed : server unreachable");
	
	//ERROR condition
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Login Error"
						  message:@"Server unreachable"
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}

@end
