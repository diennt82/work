//
//  MBPNavController.m
//  MBP_ios
//
//  Created by NxComm on 12/5/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "MBPNavController.h"

@interface MBPNavController ()

@end

@implementation MBPNavController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL) shouldAutorotate
{

    UIViewController * vc = [self.viewControllers objectAtIndex:(self.viewControllers.count -1)];
    
    return [vc shouldAutorotate];
    
    //return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    
   
    return UIInterfaceOrientationMaskAllButUpsideDown;
    
}



@end
