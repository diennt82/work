//
//  AiBallPlayViewController.m
//  AiBallRecorder
//
//  Created by NxComm on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AiBallPlayViewController.h"


@implementation AiBallPlayViewController

@synthesize filename;
@synthesize imageView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	aviPlayer = [[AiBallAviPlayer alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {	
	aviPlayer.videoSink = self;
	[aviPlayer Start:[self filename]];
	pcmPlayer = nil;
    [super viewWillAppear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
	
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
	        (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
	
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [aviPlayer Stop];
	if(pcmPlayer != nil) {
		[pcmPlayer Stop];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    [aviPlayer Stop];
	if(pcmPlayer != nil) {
		[pcmPlayer Stop];
	}
	[super viewWillAppear:animated];
}

- (void)onVideoEnd
{
	if(pcmPlayer != nil) {
		[[pcmPlayer player] setPlay_now:FALSE];
		[pcmPlayer Stop];
		[pcmPlayer release];
		pcmPlayer = nil;
	}
	
	//[[self navigationController] popViewControllerAnimated: YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) stopPlayback: (id) sender 
{
	//[[self navigationController] popViewControllerAnimated: YES];	
	if(pcmPlayer != nil) {
		[[pcmPlayer player] setPlay_now:FALSE];
		[pcmPlayer Stop];
		[pcmPlayer release];
		pcmPlayer = nil;
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void) onPCM:(NSData*)pcm
{
	if(pcmPlayer == nil) {
		pcmPlayer = [[PCMPlayer alloc] init];
		[pcmPlayer Play:FALSE];
		[[pcmPlayer player] setPlay_now:TRUE];
	}
	
	[pcmPlayer WritePCM:(unsigned char*)[pcm bytes] length:[pcm length]];
}

- (void) onFrame:(NSData*)frame
{
	UIImage *image = [UIImage imageWithData:frame];
	self.imageView.image = image;
}

- (void)dealloc {
	[aviPlayer release];
	if(pcmPlayer != nil) {
		[pcmPlayer release];
		pcmPlayer = nil;
	}
    [super dealloc];
}


@end
