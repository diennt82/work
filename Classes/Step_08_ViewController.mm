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
    self.navigationItem.title = @"Camera Configured"; 
    ssidView.text = self.ssid;
    ssidView_1.text = self.ssid;
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
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
    Step_09_ViewController *step09ViewController = [[Step_09_ViewController alloc]
                                                    initWithNibName:@"Step_09_ViewController" bundle:nil];
    

    [self.navigationController pushViewController:step09ViewController animated:NO];
    
    [step09ViewController release];
    
}
@end
