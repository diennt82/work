//
//  MBP_FirstPage.m
//  MBP_ios
//
//  Created by NxComm on 4/24/12.
//  Copyright 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBP_FirstPage.h"


@implementation MBP_FirstPage




 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withConnDelegate:(id<ConnectionMethodDelegate>) d  {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        // Custom initialization
		
		delegate = d;
    }
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Read version 
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    version = [NSString stringWithFormat:@"Version %@",version]; 
    versionText.text =version;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;


}


//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
//	        (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
//}


- (BOOL) shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
   
    return UIInterfaceOrientationMaskPortrait;
    
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


- (IBAction) handleButtonPressed:(id) sender
{
	int sender_tag = ((UIButton *) sender).tag;
	
	switch (sender_tag) {
        case ACTION_SETUP_BM:
		{ 
            NSLog(@"AcTION SETUP BM"); 
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setBool:TRUE forKey:FIRST_TIME_SETUP];
			[userDefaults synchronize];
		
            [delegate sendStatus:1];
            
			break; 
		}
		case ACTION_LOGIN:
		{
            
            [delegate sendStatus:2];
			break;
		}
		default:
			break;
	}
}
@end
