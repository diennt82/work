//
//  Bonjour.m
//  MBP_ios
//
//  Created by nxcomm on 06/05/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "Bonjour.h"
#define DOMAINS @"local"
#define SERVICE @"_camera._tcp"

@interface Bonjour ()
@end

@implementation Bonjour

@synthesize isSearching;
@synthesize timer;
@synthesize delegate;
@synthesize serviceArray;
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
    isSearching = NO;
    
    if (self.serviceArray == nil)
    {
        self.serviceArray = [[NSMutableArray alloc] init];
    }
    
    if (!_browserService)
    {
        _browserService = [[NSNetServiceBrowser alloc]init];
        [_browserService setDelegate:self];
    }
    
    [_browserService searchForServicesOfType:SERVICE inDomain:DOMAINS];
    
}
#pragma mark -
#pragma mark NSNetServiceDelegate

#pragma mark -
#pragma mark NSNetResolveDelegate
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [timer release];
    delegate = nil;
    [serviceArray removeAllObjects];
    [super dealloc];
}
@end
