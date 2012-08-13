//
//  MBP_SetupViewController.m
//  MBP_ios
//
//  Created by NxComm on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_MainSetupViewController.h"
#import "MBP_DeviceConfigureViewController.h"
#import "MBP_DeviceScanViewController.h"
#import "MBP_RemoteAccessViewController.h"
#import "Util.h"
#import "PublicDefine.h"

@implementation MBP_MainSetupViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
		 withDelegate:(id<SetupHttpDelegate>) delegate
{
	NSLog(@"Brightness Init\n");
	brightness = DEFAULT_BRIGHTNESS_LVL;
	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		httpDelegate = delegate;
    }
    return self;
}

- (void ) requestURLSync_bg:(NSString*)url {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	//incase of demo, don't send the request
	
	{
		NSLog(@"url : %@", url);
		
		/* use a small value of timeout in this case */
		[self requestURLSync:url withTimeOut:IRABOT_HTTP_REQ_TIMEOUT];
	}
	
	[pool release];
}

/* Just use in background only */
- (NSString * ) requestURLSync:(NSString*)url withTimeOut:(NSTimeInterval) timeout 
{
	
	//NSLog(@"send request: %@", url);
	
	NSURLResponse* response;
	NSError* error = nil;
	NSData *dataReply = nil;
	NSString * stringReply = nil;
	
	
	@synchronized(self)
	{
		
		// Create the request.
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
																cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:timeout];
		NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", [Util getCredentials]];  
		[theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
		
		dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		
		
		if (error != nil)
		{
			//NSLog(@"error: %@\n", error);
		}
		else {
			
			// Interpret the response
			stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
			[stringReply autorelease];
		}
		
		
	}
	
	
	return stringReply ;
}

- (int)  setVideoContrast:(int) newValue
{
	
	if (newValue != contrast)
	{
		contrast = newValue;
		
		[self performSelectorInBackground:@selector(setContrast_bg) 
							   withObject:nil];	
	}
	return newValue;
	
}
- (int)  setVideoBrightness:(int) newValue
{
		
	if (newValue != brightness)
	{
		brightness = newValue;
		
		
		[self performSelectorInBackground:@selector(setBrightness_bg) 
							   withObject:nil];	
	}
	return newValue;
}

- (void) setContrast_bg
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSString * response = nil;
	int cur_value = -1, new_contrast;
	NSRange range ; 
	
	
	@synchronized(self)
	{
		new_contrast = contrast;
		//NSLog(@"newContrast: %d", new_contrast);
		do 
		{
			
			//Get the current contrast value
			response = [self requestURLSync:[Util getContrastValueURL] 
								withTimeOut:1.0];
			
			
			
			
			
			if ( response != nil && 
				[response hasPrefix:@"value_contract: "] ) ///contrast .. no contract xxx
			{
				range.location = [@"value_contract: " length];
				range.length = 1;
				cur_value = [[response substringWithRange:range] intValue];
				
				//TODO: Sanity check : cur_value in {0,8}
				
				if (cur_value < new_contrast)
				{
					[self requestURLSync:[Util getContrastPlusURL]
							 withTimeOut:1.0];
				}
				else if (cur_value > new_contrast)
				{
					[self requestURLSync:[Util getContrastMinusURL] 
							 withTimeOut:1.0];
				}
				
				
			}
			
		} 
		while (cur_value != new_contrast);
		
	}
	
	
	
	[pool release];
}

- (void) setBrightness_bg 
{
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSString * response = nil;
	int cur_value = -1, new_brightness;
	NSRange range ; 
	
	
	@synchronized(self)
	{
		
		new_brightness = brightness;
		do 
		{
			
			//Get the current brightness value
			response = [self requestURLSync:[Util getBrightnessValueURL]
								withTimeOut:1.0];
			
			if ( response != nil && 
				[response hasPrefix:@"value_brightness: "] )
			{
				range.location = [@"value_brightness: " length];
				range.length = 1;
				cur_value = [[response substringWithRange:range] intValue];
				
				//TODO: Sanity check : cur_value in {0,8}
				
				if (cur_value < new_brightness)
				{
					[self requestURLSync:[Util getBrightnessPlusURL]
							 withTimeOut:1.0];
					
					
				}
				else if (cur_value > new_brightness)
				{
					[self requestURLSync:[Util getBrightnessMinusURL]
							 withTimeOut:1.0];
					
				}
				
				
			}
			
		}
		while (cur_value != new_brightness); // end while 
		
	}
	
	[pool release];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad {
    [super viewDidLoad];
}
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
	
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
#pragma mark -
#pragma mark Button Handling 


- (IBAction) _handleButtonPressed:(id) sender
{
	int sender_tag = ((UIButton *) sender).tag;

	switch (sender_tag) {
		case CONFIGURE_BUTTON_TAG:
		{

			MBP_DeviceConfigureViewController * setupController;
			setupController = [[MBP_DeviceConfigureViewController alloc] initWithNibName:@"MBP_DeviceConfigureViewController"
																				  bundle:nil
																			withDelegate:httpDelegate ];
			
			[self presentModalViewController:setupController animated:YES];

			break;
		}
		case SCAN_BUTTON_TAG:
		{
			
			MBP_DeviceScanViewController * scanController;
			scanController = [[MBP_DeviceScanViewController alloc] initWithNibName:@"MBP_DeviceScanViewController"
																			bundle:nil ];
			
			[self presentModalViewController:scanController animated:YES];
			
			break;
		}
			

		case ADV_BUTTON_TAG:
		{
			MBP_RemoteAccessViewController * remoteController;
			remoteController = [[MBP_RemoteAccessViewController alloc] initWithNibName:@"MBP_RemoteAccessViewController"
																				bundle:nil];
			[self presentModalViewController:remoteController animated:YES];
			break;
		}
		case MENU_SETUP_BACK_KEY_TAG:
			[self dismissModalViewControllerAnimated:YES];
			break;
		case BRIGHTNESS_1_BUTTON_TAG:
			NSLog(@"Brightness 1\n");
			[self setVideoBrightness:(int)(3)];
			break;
		case ASPECT_RATIO_43_BUTTON_TAG:
			break;
		case BRIGHTNESS_2_BUTTON_TAG:	
			NSLog(@"Brightness 2\n");
			[self setVideoBrightness:(int)(4)];
			break;
		case BRIGHTNESS_3_BUTTON_TAG:	
			NSLog(@"Brightness 3\n");
			[self setVideoBrightness:(int)(5)];
			break;
		case BRIGHTNESS_4_BUTTON_TAG:	
			NSLog(@"Brightness 4\n");
			[self setVideoBrightness:(int)(6)];
			break;
		default:
			break;
	}
	
}


@end
