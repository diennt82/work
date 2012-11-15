//
//  Setup_04_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_04_ViewController.h"

@interface Step_04_ViewController ()

@end

@implementation Step_04_ViewController

@synthesize cameraMac, cameraName;
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
    self.navigationItem.title = @"Camera Detected";
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    

    camName.text = self.cameraName;
    
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

-(void) dealloc
{

    [cameraName release];
   [cameraMac release];
    [super dealloc];
}

- (IBAction)handleButtonPress:(id)sender
{
    int tag = ((UIButton*)sender).tag; 
    
    if (tag == CONF_CAM_BTN_TAG)
    {
        

        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:camName.text forKey:@"CameraName"];
        [userDefaults synchronize];
        
        
        comm = [[HttpCommunication alloc]init];
        comm.device_ip = @"192.168.2.1";//here camera is still in directmode
        comm.device_port = 80; 
        //Authenticate first
        [comm babymonitorAuthentication];
        
        
        [NSTimer scheduledTimerWithTimeInterval: 0.125//0.04 
                                         target:self
                                       selector:@selector(isAuthenticationDone:)
                                       userInfo:nil
                                        repeats:NO];

    }
}



- (void) isAuthenticationDone:(NSTimer *) expired
{
	if (comm.authInProgress == FALSE)
	{
		NSLog(@"bm auth passed!");
		[self queryWifiList];
		
	}
	else 
	{
		[NSTimer scheduledTimerWithTimeInterval:1//0.04 
										 target:self
									   selector:@selector(isAuthenticationDone:)
									   userInfo:nil
										repeats:NO];
	}
	
}



-(void) queryWifiList
{
    NSData * router_list_raw; 
       
    
    router_list_raw = [comm sendCommandAndBlock_raw:GET_ROUTER_LIST];
    
    if (router_list_raw != nil)
    {
        WifiListParser * routerListParser = nil;
        routerListParser = [[WifiListParser alloc]init];
        
        [routerListParser parseData:router_list_raw
                       whenDoneCall:@selector(setWifiResult:)
                             target:self];
    }
    else
    {
        NSLog(@"GOT NULL wifi list from camera"); 
    }
}


-(void) setWifiResult:(NSArray *) wifiList
{
    NSLog(@"GOT WIFI RESULT: numentries: %d", wifiList.count); 
    
   
    
    
#if 0
     WifiEntry * entry; 
    for (int i =0; i< wifiList.count; i++)
    {
        entry = [wifiList objectAtIndex:i]; 
        
        
        NSLog(@"entry %d : %@",i, entry.ssid_w_quote);
        NSLog(@"entry %d : %@",i, entry.bssid);
        NSLog(@"entry %d : %@",i, entry.auth_mode);
        NSLog(@"entry %d : %@",i, entry.quality);
    }
#endif 
    
    
    
    NSLog(@"Load step 5"); 
    //Load the next xib
    Step_05_ViewController *step05ViewController = [[Step_05_ViewController alloc]
                                                    initWithNibName:@"Step_05_ViewController" bundle:nil];
    
    
    step05ViewController.listOfWifi = [[NSMutableArray alloc]initWithArray:wifiList];
    
    [self.navigationController pushViewController:step05ViewController animated:NO];
    
    [step05ViewController release];
    
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}



@end
