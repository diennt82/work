//
//  Step_02_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_02_ViewController.h"

@interface Step_02_ViewController ()

@end

@implementation Step_02_ViewController

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

    self.navigationItem.title = @"Switch On Camera";

 

    
    //Setup now but this button will only be seen when go to the NEXT controller
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
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

- (IBAction)handleButtonPress:(id)sender
{
    int tag = ((UIButton*)sender).tag; 
    
    if (tag == CONTINUE_BTN_TAG)
    {
#if 1
        NSLog(@"Load step 3"); 
        //Load the next xib
        Step_03_ViewController *step03ViewController = [[Step_03_ViewController alloc]
                                                        initWithNibName:@"Step_03_ViewController" bundle:nil];
        
        [self.navigationController pushViewController:step03ViewController animated:NO];
        
        [step03ViewController release];
        
        
        
#else //TEST ONLY 
      
#endif
    }
    
    
}

@end
