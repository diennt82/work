//
//  MBP_MainCameraView.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBP_MainCameraView.h"


@implementation MBP_MainCameraView

@synthesize videoView;
@synthesize directionPad, directionIndicator;
@synthesize viewController;
@synthesize progressView;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) initializedWithViewController:(MBP_iosViewController *) viewctlr
{
    CGRect frame = self.directionPad.frame;	
	
	translation_down_limit =  frame.size.height/2.0 - directionIndicator.frame.size.height/2.0 ;
	translation_right_limit= frame.size.width/2.0	- directionIndicator.frame.size.width/2.0 ;			
	translation_up_limit = - translation_down_limit;
	translation_left_limit = translation_up_limit;
	
	NSLog(@"initializedWithViewController ");
	self.viewController = viewctlr;
	
	
}




- (void)dealloc {
	
	[videoView release];
	[directionPad release];
	[directionIndicator release];
	[viewController  release];
	[progressView release];
    [super dealloc];
}

#pragma mark touches

#define VIEW_DIRECTIONPAD_TAG 500
#define VIEW_DIRECTIONIND_TAG 501

//----- handle all touches here then propagate into directionview 

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch;
	CGPoint location ;	
	NSSet *allTouches = [event allTouches];
	
	[super touchesBegan:touches withEvent:event];
	
	//NSLog(@"began Touches count: %d", [allTouches count]);
	[self.viewController showSideMenusAndStatus];
	
	int i =0;
	
	for (i =0 ; i < [allTouches count]; i++)
	{
		touch = [ [allTouches allObjects] objectAtIndex:i] ;
	
		location = [touch locationInView:touch.view];
		
	
		if (touch.view.tag == VIEW_DIRECTIONPAD_TAG)
		{
			//NSLog(@"touched view: loc: %f %f", location.x, location.y);
			[self.viewController showJoysticksOnly];
			[self touchEventAt:location phase:touch.phase];
		}
			
	}
	
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
	UITouch *touch;
	CGPoint location ;	
	NSSet *allTouches = [event allTouches];
	[super touchesEnded:touches withEvent:event];
	///NSLog(@"Ended Touches count: %d", [allTouches count]);
	int i =0;

	[self.viewController tryToShowFullScreen];
	
	for (i =0 ; i < [allTouches count]; i++)
	{
		touch = [ [allTouches allObjects] objectAtIndex:i] ;
		//NSLog(@"touched view:Tag:%d", touch.view.tag);
		location = [touch locationInView:touch.view];
		
		if (touch.view.tag == VIEW_DIRECTIONPAD_TAG)
		{
			
			[self touchEventAt:location phase:touch.phase];
		}
		
		
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch;
	CGPoint location ;	
	NSSet *allTouches = [event allTouches];


	[super touchesMoved:touches withEvent:event];
	//NSLog(@" MOVED Touches count: %d", [allTouches count]);
	int i =0;
	
	for (i =0 ; i < [allTouches count]; i++)
	{
		touch = [ [allTouches allObjects] objectAtIndex:i] ;
		//NSLog(@"touched view:Tag:%d", touch.view.tag);
		location = [touch locationInView:touch.view];
		
		if (touch.view.tag == VIEW_DIRECTIONPAD_TAG)
		{
			

			
			[self touchEventAt:location phase:touch.phase];
		}
		
		
	}
	
}





- (void) validatePoint: (CGPoint)location andTranslateV:(UIView*) view began: (BOOL)isBegan
{
	CGPoint translation ;
	
	BOOL is_vertical;
	/* check against outer boundary limit*/
	if (location.y >(translation_down_limit +beginLocation.y ))
	{
		location.y = translation_down_limit +beginLocation.y;
	}
	else if (location.y < (translation_up_limit +beginLocation.y ))
	{
		location.y = translation_up_limit +beginLocation.y;
	}
	
	if (location.x >(translation_right_limit +beginLocation.x ))
	{
		location.x = translation_right_limit +beginLocation.x;
	}
	else if (location.x < (translation_left_limit +beginLocation.x ))
	{
		location.x = translation_left_limit +beginLocation.x;
	}
	
	/* check against inners boundary limit*/
	
	/* 20110804: define some small boundary in which we asume that the 
	 location is the same as the center. 
	 */
	if (  (location.y > (beginLocation.y - 5)) && (location.y < (beginLocation.y+5) ))
	{
		location.y = beginLocation.y;
	}
	if (  (location.x > (beginLocation.x - 5)) && (location.x < (beginLocation.x+5) ))
	{
		location.x = beginLocation.x;
	}
	
	//NSLog(@"val: loc: %f %f", location.x, location.y);
	//NSLog(@"val: begin: %f %f", beginLocation.x, beginLocation.y);
	
	
	translation.x =  location.x - beginLocation.x;
	translation.y =  location.y - beginLocation.y;
	//NSLog(@"val: tran: %f %f", translation.x, translation.y);
	is_vertical = YES;
	if ( abs(translation.x) >  abs(translation.y))
	{
		is_vertical = NO;
	}
	
	
	if (is_vertical == YES)
	{
		view.transform = CGAffineTransformMakeTranslation(0, translation.y);
		if (isBegan)
		{
			[viewController updateVerticalDirection_begin:translation.y inStep:0];
		}
		else
		{
			[viewController updateVerticalDirection:translation.y inStep:0 withAnimation:FALSE];
		}
	
	}
	else
	{
		
		view.transform = CGAffineTransformMakeTranslation( translation.x,0);
		if (isBegan)
		{ 
			[viewController updateHorizontalDirection_begin:translation.x inStep:0];
		}
		else {
			
			[viewController updateHorizontalDirection:translation.x inStep:0 withAnimation:FALSE];
		}		
	}
	
}


- (void) touchEventAt:(CGPoint) location phase:(UITouchPhase) phase
{
	
	switch (phase) {
		case UITouchPhaseBegan:
			[self _touchesbegan:location];
			break;
		case UITouchPhaseMoved:
		case UITouchPhaseStationary:
			[self _touchesmoved:location];
			break;
		case UITouchPhaseEnded:
			[self _touchesended:location];
			
		default:
			break;
	}
}

- (void) _touchesbegan: (CGPoint) location
{
	
	/* notes: location(x,y) is in the directionPad coordinate 
	           directionIndicator.center(x,y) is in mainCamView coord
	 To make sure the calculation is correct, we need to transform the directionIndicator 
	 center to directionPad coordinate 
	 */
	directionIndicator.highlighted = YES;
	
	beginLocation.x = directionIndicator.center.x - directionPad.frame.origin.x;
	beginLocation.y = directionIndicator.center.y - directionPad.frame.origin.y;
	
	
	[self validatePoint:location andTranslateV:(UIView*)directionIndicator began:YES];
	
	
	
}

- (void) _touchesmoved: (CGPoint) location
{
	[self validatePoint:location andTranslateV:(UIView*)directionIndicator began:NO];
}

- (void) _touchesended: (CGPoint) location
{
	
	[self validatePoint:location andTranslateV:(UIView*)directionIndicator began:NO];
	
	directionIndicator.highlighted = NO;
	directionIndicator.transform = CGAffineTransformMakeTranslation(0, 0);	
	
	
#if 1

		[viewController updateVerticalDirection_end:0 inStep:0];

		[viewController updateHorizontalDirection_end:0 inStep:0];
#endif 
	
}


@end
