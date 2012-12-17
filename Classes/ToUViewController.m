//
//  ToUViewController.m
//  MBP_ios
//
//  Created by NxComm on 1/11/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "ToUViewController.h"

@interface ToUViewController ()

@end

@implementation ToUViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [termOfUse loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL fileURLWithPath:
       [[NSBundle mainBundle] pathForResource:@"MonitorEverywhere_App_ios_Apple" ofType:@"html"] ] ] ];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
