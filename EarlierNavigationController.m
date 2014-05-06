//
//  EarlierNavigationController.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 28/2/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "EarlierNavigationController.h"

@interface EarlierNavigationController ()

@end

@implementation EarlierNavigationController
@synthesize isEarlierView = _isEarlierView;
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
    _isEarlierView = NO;
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

//-(NSUInteger)supportedInterfaceOrientations
//{
//    
//    if (_isEarlierView)
//    {
//        return UIInterfaceOrientationMaskPortrait;
//    }
//    
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//    
//}

@end
