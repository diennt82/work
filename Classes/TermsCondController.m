//
//  TermsCondController.m
//  BlinkHD_ios
//
//  Created by openxcell on 5/15/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import "TermsCondController.h"

@interface TermsCondController ()
    
@end

@implementation TermsCondController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   self.navigationController.navigationBarHidden = NO;
    [self.navigationItem setTitle:@"Terms & Conditions"];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"terms_of_use" withExtension:@"html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_webViewTC loadRequest:request];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)dealloc
{
    _webViewTC.delegate = nil;
    [_webViewTC release];
    [super dealloc];
}

-(void)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
