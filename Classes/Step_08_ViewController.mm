//
//  Step_08_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/26/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_08_ViewController.h"

@interface Step_08_ViewController ()

@end

@implementation Step_08_ViewController
@synthesize  ssid;

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
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"Camera_Configured",nil, [NSBundle mainBundle],
                                                                  @"Camera Configured" , nil);
    ssidView.text = self.ssid;
    ssidView_1.text = self.ssid;
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                                              @"Back" , nil)
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    
    //check back later..
    [NSTimer scheduledTimerWithTimeInterval: 2.0//
                                     target:self
                                   selector:@selector(checkConnectionToHomeWifi:)
                                   userInfo:nil
                                    repeats:NO];

    
    
}

-(void) dealloc
{
    [ssid release];
    [super dealloc];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)handleButtonPress:(id)sender
{    
    NSLog(@"Load step 09");
    
    
    //Load the next xib
    Step_09_ViewController *step09ViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        step09ViewController = [[Step_09_ViewController alloc]
                                initWithNibName:@"Step_09_ViewController_ipad" bundle:nil];
        
        
    }
    else
    {
      
        
        step09ViewController = [[Step_09_ViewController alloc]
                                initWithNibName:@"Step_09_ViewController" bundle:nil];
        
        
    }


    [self.navigationController pushViewController:step09ViewController animated:NO];
    
    [step09ViewController release];
    
}

#pragma  mark -
#pragma mark Timer callbacks

- (void) checkConnectionToHomeWifi:(NSTimer *) expired
{
    
    
    NSString * currentSSID = [CameraPassword fetchSSIDInfo];
    
    
    
    NSLog(@"checkConnectionToHomeWifi 03: %@", currentSSID);
	if ([currentSSID isEqualToString:self.ssid])
	{
		//yeah we're connected ... check for ip??
		
		NSString * bc = @"";
		NSString * own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
		
		if (![own isEqualToString:@""])
		{
			
            //20121130: phung: save it here.. so that we can automatically check later on.
            if (self.ssid != nil)
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:self.ssid forKey:HOME_SSID];
                [userDefaults synchronize];
            }
            
            //create account now... 
            [self handleButtonPress:nil];
            
			return;
		}
		
	}
    
    //check back later..
    [NSTimer scheduledTimerWithTimeInterval: 3.0//
                                     target:self
                                   selector:@selector(checkConnectionToHomeWifi:)
                                   userInfo:nil
                                    repeats:NO];
	
}


#pragma mark -


@end
