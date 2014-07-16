//
//  UICircularSlider.m
//  UICircularSlider
//
//  Created by Zouhair Mahieddine on 02/03/12.
//  Copyright (c) 2012 Zouhair Mahieddine.
//  http://www.zedenem.com
//  
//  This file is part of the UICircularSlider Library, released under the MIT License.
//

#import "UICircularSlider.h"
#import "UIFont+Hubble.h"
#import "define.h"

@interface UICircularSlider()
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )


@property (nonatomic) CGPoint thumbCenterPoint;

#pragma mark - Init and Setup methods
- (void)setup;

#pragma mark - Thumb management methods
- (BOOL)isPointInThumb:(CGPoint)point;

#pragma mark - Drawing methods
- (CGFloat)sliderRadius;
- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint inContext:(CGContextRef)context;
- (CGPoint)drawCircularTrack:(float)track atPoint:(CGPoint)point withRadius:(CGFloat)radius inContext:(CGContextRef)context;
- (CGPoint)drawPieTrack:(float)track atPoint:(CGPoint)point withRadius:(CGFloat)radius inContext:(CGContextRef)context;

@end

#pragma mark -
@implementation UICircularSlider

@synthesize value = _value;
@synthesize textField = _textField;
- (void)setValue:(float)value {
	if (value != _value) {
		if (value > self.maximumValue) { value = self.maximumValue; }
		if (value < self.minimumValue) { value = self.minimumValue; }
		_value = value;
        [self.textField setText:[self timeFormat:(int)round(self.value)]];
		[self setNeedsDisplay];
//        if (self.isContinuous) {
//            [self sendActionsForControlEvents:UIControlEventValueChanged];
//        }
	}
}
@synthesize minimumValue = _minimumValue;
- (void)setMinimumValue:(float)minimumValue {
	if (minimumValue != _minimumValue) {
		_minimumValue = minimumValue;
		if (self.maximumValue < self.minimumValue)	{ self.maximumValue = self.minimumValue; }
		if (self.value < self.minimumValue)			{ self.value = self.minimumValue; }
	}
}
@synthesize maximumValue = _maximumValue;
- (void)setMaximumValue:(float)maximumValue {
	if (maximumValue != _maximumValue) {
		_maximumValue = maximumValue;
		if (self.minimumValue > self.maximumValue)	{ self.minimumValue = self.maximumValue; }
		if (self.value > self.maximumValue)			{ self.value = self.maximumValue; }
	}
}

@synthesize minimumTrackTintColor = _minimumTrackTintColor;
- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
	if (![minimumTrackTintColor isEqual:_minimumTrackTintColor]) {
		_minimumTrackTintColor = minimumTrackTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize maximumTrackTintColor = _maximumTrackTintColor;
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
	if (![maximumTrackTintColor isEqual:_maximumTrackTintColor]) {
		_maximumTrackTintColor = maximumTrackTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize thumbTintColor = _thumbTintColor;
- (void)setThumbTintColor:(UIColor *)thumbTintColor {
	if (![thumbTintColor isEqual:_thumbTintColor]) {
		_thumbTintColor = thumbTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize continuous = _continuous;

@synthesize sliderStyle = _sliderStyle;
- (void)setSliderStyle:(UICircularSliderStyle)sliderStyle {
	if (sliderStyle != _sliderStyle) {
		_sliderStyle = sliderStyle;
		[self setNeedsDisplay];
	}
}

@synthesize thumbCenterPoint = _thumbCenterPoint;

/** @name Init and Setup methods */
#pragma mark - Init and Setup methods
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    } 
    return self;
}
- (void)awakeFromNib {
	[self setup];
}

- (void)dealloc {
    [_textField release];
    [_minuteTField release];
    [_minimumTrackTintColor release];
    [_maximumTrackTintColor release];
    [_thumbTintColor release];
    [_timer release];
    [super dealloc];
}

- (void)setup {
	self.value = 0.0;
	self.minimumValue = 0.0;
	self.maximumValue = 180.0;

    self.minimumTrackTintColor = Rgb2UIColor(96,170,243);
	self.maximumTrackTintColor = Rgb2UIColor(65,85,97);
	self.continuous = YES;
    self.thumbTintColor = Rgb2UIColor(223, 237, 244);
	self.thumbCenterPoint = CGPointZero;
    //Add label
    //Define the Font

    UIFont *font = [UIFont lightLarge75Font];
    UIFont *font1 = [UIFont regularMedium23Font];
    //Calculate font size needed to display 3 numbers
    NSString *str = @"0000";
    NSString *minites = @"minutes";
    CGSize fontSize = [str sizeWithAttributes:@{NSFontAttributeName: font}];
    CGSize fontSize1 = [minites sizeWithAttributes:@{NSFontAttributeName: font1}];
    
    //Using a TextField area we can easily modify the control to get user input from this field
    _textField = [[UITextField alloc]initWithFrame:CGRectMake((self.frame.size.width  - fontSize.width) /2,
                                                              (self.frame.size.height - fontSize.height) /2 - 10,
                                                              fontSize.width,
                                                              fontSize.height)];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.textColor = [UIColor colorWithWhite:1 alpha:1];
    _textField.textAlignment = NSTextAlignmentCenter;
    _textField.text = @"0";
    _textField.font = font;
    _textField.enabled = NO;
    
    
    _minuteTField = [[UITextField alloc]initWithFrame:CGRectMake((self.frame.size.width  - fontSize1.width) /2,
                                                                       (self.frame.size.height - fontSize1.height) /2 + fontSize1.height + 5 ,
                                                                       fontSize1.width,
                                                                       fontSize1.height)];
    
    _minuteTField.backgroundColor = [UIColor clearColor];
    _minuteTField.textColor = [UIColor colorWithWhite:1 alpha:1];
    _minuteTField.textAlignment = NSTextAlignmentCenter;
    _minuteTField.text = @"minutes";
    _minuteTField.font = font1;
    _minuteTField.enabled = NO;
    
    [self addSubview:_textField];
    [self addSubview:_minuteTField];

    
    /**
     * This tapGesture isn't used yet but will allow to jump to a specific location in the circle
     */
//	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHappened:)];
//	[self addGestureRecognizer:tapGestureRecognizer];
	
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHappened:)];
	panGestureRecognizer.maximumNumberOfTouches = panGestureRecognizer.minimumNumberOfTouches;
	[self addGestureRecognizer:panGestureRecognizer];
    
    [self addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];
    
    [self setUserInteractionEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(becomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    

}

-(void) handleEnteredBackground
{
    //save value to handle later
    //NSTimeInterval nowInterval =
    [[NSDate date] timeIntervalSince1970];
    
}

-(void) becomeActive
{
    //load from save value and update UI
    [self updateCustomSlider];
}

- (void)updateCustomSlider
{
    NSInteger nowInterval = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger timeExpire = [userDefaults integerForKey:TIME_TO_EXPIRED];
    NSInteger deltaTime = nowInterval - timeExpire;
    if (deltaTime >= 0)
    {
        self.value = 0;
    }
    else
    {
        self.value = round(abs(deltaTime)/60.0);
    }

}
#pragma mark - Timer to udpate text
- (void)updateProgress: (UICircularSlider *) sender
{
    [self setValue:self.value];
}

- (void)updateLabel:(NSTimer *)exp{
    NSInteger value = (int)round(self.value);
	if((int)self.value == 0 || self.value > 180 || !self.userInteractionEnabled){
		[self killTimer];
	}
	self.textField.text = [self timeFormat:value];
    value = value -1;
	self.value = value;
}

- (void)killTimer{
	if(_timer && [_timer isValid]){
		[_timer invalidate];
		_timer = nil;
	}
}

- (NSString *) timeFormat: (int) minutes {
    
    if (minutes < 60)
    {
        NSString *cm = minutes <= 9 ? @"0": @"";
        return [NSString stringWithFormat:@"%@%d",cm, minutes];
    }
    else
    {
        int hours = minutes / 60;
        NSString *cm = minutes <= 9 ? @"0": @"";
        int newMinutes = fabs(round((int)minutes % 60));
        
        
        
        NSString *cs = newMinutes <= 9 ? @"0": @"";
        
        return [NSString stringWithFormat:@"%@%ih%@%i",cm, hours, cs, newMinutes];
    }

    
}

/** @name Drawing methods */
#pragma mark - Drawing methods
#define kLineWidth 10.0
#define kThumbRadius 15.0
- (CGFloat)sliderRadius {
	CGFloat radius = MIN(self.bounds.size.width/2, self.bounds.size.height/2);
	radius -= MAX(kLineWidth, kThumbRadius);	
	return radius;
}
- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint inContext:(CGContextRef)context {
	UIGraphicsPushContext(context);
	CGContextBeginPath(context);
	
	CGContextMoveToPoint(context, sliderButtonCenterPoint.x, sliderButtonCenterPoint.y);
	CGContextAddArc(context, sliderButtonCenterPoint.x, sliderButtonCenterPoint.y, kThumbRadius, 0.0, 2*M_PI, NO);
	
	CGContextFillPath(context);
	UIGraphicsPopContext();
}

- (CGPoint)drawCircularTrack:(float)track atPoint:(CGPoint)center withRadius:(CGFloat)radius inContext:(CGContextRef)context {
	UIGraphicsPushContext(context);
	CGContextBeginPath(context);
	
	float angleFromTrack = translateValueFromSourceIntervalToDestinationInterval(track, self.minimumValue, self.maximumValue, 0, 2*M_PI);
	
	CGFloat startAngle = M_PI_2;
	CGFloat endAngle = startAngle + angleFromTrack;
	CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, NO);
	
	CGPoint arcEndPoint = CGContextGetPathCurrentPoint(context);
	
	CGContextStrokePath(context);
	UIGraphicsPopContext();
	
	return arcEndPoint;
}

- (CGPoint)drawPieTrack:(float)track atPoint:(CGPoint)center withRadius:(CGFloat)radius inContext:(CGContextRef)context {
	UIGraphicsPushContext(context);
	
	float angleFromTrack = translateValueFromSourceIntervalToDestinationInterval(track, self.minimumValue, self.maximumValue, 0, 2*M_PI);
	
	CGFloat startAngle = M_PI_2;
	CGFloat endAngle = startAngle + angleFromTrack;
	CGContextMoveToPoint(context, center.x, center.y);
	CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, NO);
	
	CGPoint arcEndPoint = CGContextGetPathCurrentPoint(context);
	
	CGContextClosePath(context);
	CGContextFillPath(context);
	UIGraphicsPopContext();
	
	return arcEndPoint;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGPoint middlePoint;
	middlePoint.x = self.bounds.origin.x + self.bounds.size.width/2;
	middlePoint.y = self.bounds.origin.y + self.bounds.size.height/2;
	
	CGContextSetLineWidth(context, kLineWidth);
	
	CGFloat radius = [self sliderRadius];
	switch (self.sliderStyle) {
		case UICircularSliderStylePie:
			[self.maximumTrackTintColor setFill];
			[self drawPieTrack:self.maximumValue atPoint:middlePoint withRadius:radius inContext:context];
			[self.minimumTrackTintColor setStroke];
			[self drawCircularTrack:self.maximumValue atPoint:middlePoint withRadius:radius inContext:context];
			[self.minimumTrackTintColor setFill];
			self.thumbCenterPoint = [self drawPieTrack:self.value atPoint:middlePoint withRadius:radius inContext:context];
			break;
		case UICircularSliderStyleCircle:
		default:
			[Rgb2UIColor(65,85,97) setStroke];
			[self drawCircularTrack:self.maximumValue atPoint:middlePoint withRadius:radius inContext:context];
			//[self.minimumTrackTintColor setStroke];//used will leak, don't understand
            [Rgb2UIColor(96,170,243) setStroke];
			self.thumbCenterPoint = [self drawCircularTrack:self.value atPoint:middlePoint withRadius:radius inContext:context];
			break;
	}
	[Rgb2UIColor(223, 237, 244) setFill];
	[self drawThumbAtPoint:self.thumbCenterPoint inContext:context];
}

/** @name Thumb management methods */
#pragma mark - Thumb management methods
- (BOOL)isPointInThumb:(CGPoint)point {
	CGRect thumbTouchRect = CGRectMake(self.thumbCenterPoint.x - kThumbRadius, self.thumbCenterPoint.y - kThumbRadius, kThumbRadius*2, kThumbRadius*2);
	return CGRectContainsPoint(thumbTouchRect, point);
}
BOOL isReachLimit = NO;
int previousSweepAngle, storeAngle;
int finalAngle;

/** @name UIGestureRecognizer management methods */
#pragma mark - UIGestureRecognizer management methods
- (void)panGestureHappened:(UIPanGestureRecognizer *)panGestureRecognizer {
	CGPoint tapLocation = [panGestureRecognizer locationInView:self];
	switch (panGestureRecognizer.state) {
		case UIGestureRecognizerStateChanged: {
            [self killTimer];
			CGFloat radius = [self sliderRadius];
			CGPoint sliderCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
			CGPoint sliderStartPoint = CGPointMake(sliderCenter.x, sliderCenter.y + radius);
			CGFloat angle = angleBetweenThreePoints(sliderCenter, sliderStartPoint, tapLocation);
            NSInteger angleDegree = ToDeg(angle);
            
            if (angleDegree < 0) {
                angleDegree = -angleDegree;
            }
            else {
                angleDegree = 360 - angleDegree;
            }
            
            storeAngle = angleDegree;
            
            
            if (!isReachLimit)
            {
                
//                if (previousSweepAngle > 350 && storeAngle < 10)
                if (previousSweepAngle - storeAngle > 180)
                {
                    finalAngle = 360;
                    isReachLimit = true;
                    //NSLog(@"reach to limit 360");
                }
//                else if (previousSweepAngle < 10 && storeAngle > 180)
                else if (storeAngle - previousSweepAngle > 180)
                {
                    finalAngle = 0;
                    //NSLog(@"reach to limit zero");
                }
                else
                {
                    finalAngle = storeAngle;
                    previousSweepAngle = storeAngle;
                }
            }
            else
            {
                //NSLog(@"Normal sweep");
                if (storeAngle + 10 > previousSweepAngle)
                {
                    finalAngle = storeAngle;
                    isReachLimit = false;
                    previousSweepAngle = storeAngle;
                }
            }
            
            //check limit when slider to right value 0 minutes
			self.value = translateValueFromSourceIntervalToDestinationInterval(ToRad(finalAngle), 0, 2*M_PI, self.minimumValue, self.maximumValue);
			break;
		}
        case UIGestureRecognizerStateEnded:
            
            /**
             When is needed to register local notification
             */
            if (self.userInteractionEnabled)
            {
                NSInteger timeValue = (int)round(self.value);

                if (timeValue>0)
                {
                    //disable
                    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                }
                else
                {
                    //disable
                    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
                }
                [self cancelAllLocalNotification];
                /*Check todo
                 1. create local notification, from now
                 */
                [self registerLocalNotification];
                //timer to update after one minutes
                [self startTimerUpdateLabel];
            }
            
            if (!self.isContinuous) {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            if ([self isPointInThumb:tapLocation]) {
                [self sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else {
                [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
            }
            break;
		default:
			break;
	}
}

- (void)startTimerUpdateLabel
{
    [self killTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                              target:self
                                            selector:@selector(updateLabel:)
                                            userInfo:nil
                                             repeats:YES ];
}
- (void)setEnableView:(BOOL)isEnable {
    
}
- (void)cancelAllLocalNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
- (void)registerLocalNotification
{
    // Get the current date
    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
    NSLog(@"picker Date is %f", nowInterval);
    
    //get value of slider currently
    NSTimeInterval timeRemider = (NSTimeInterval)round(self.value) * 60;
    NSTimeInterval nextDateTime = nowInterval + timeRemider;
    NSLog(@"nextDay Date is %f and time to store is %d", nextDateTime, (int)nextDateTime);
    
    //save time to exp to call expire later
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:(int)nextDateTime forKey:TIME_TO_EXPIRED];
    [userDefaults synchronize];
   
    // Schedule the notification
    NSDate *fireDateNotification = [NSDate dateWithTimeIntervalSince1970:nextDateTime];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDateNotification;
    localNotification.alertBody = @"Your 'Do Not Disturb' time is over, you will now start to receive notifications";
    localNotification.alertAction = @"Let push notification from camera";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    //
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    [localNotification release];
}
//- (void)tapGestureHappened:(UITapGestureRecognizer *)tapGestureRecognizer {
//	if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
//		CGPoint tapLocation = [tapGestureRecognizer locationInView:self];
//		if ([self isPointInThumb:tapLocation]) {
//		}
//		else {
//		}
//	}
//}

/** @name Touches Methods */
#pragma mark - Touches Methods
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//    
//    UITouch *touch = [touches anyObject];
//    CGPoint touchLocation = [touch locationInView:self];
//    if ([self isPointInThumb:touchLocation]) {
//        [self sendActionsForControlEvents:UIControlEventTouchDown];
//    }
//}

@end

/** @name Utility Functions */
#pragma mark - Utility Functions
float translateValueFromSourceIntervalToDestinationInterval(float sourceValue, float sourceIntervalMinimum, float sourceIntervalMaximum, float destinationIntervalMinimum, float destinationIntervalMaximum) {
	float a, b, destinationValue;
	
	a = (destinationIntervalMaximum - destinationIntervalMinimum) / (sourceIntervalMaximum - sourceIntervalMinimum);
	b = destinationIntervalMaximum - a*sourceIntervalMaximum;
	
	destinationValue = a*sourceValue + b;
	
	return destinationValue;
}

CGFloat angleBetweenThreePoints(CGPoint centerPoint, CGPoint p1, CGPoint p2) {
	CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
	CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);
	
	CGFloat angle = atan2f(v2.x*v1.y - v1.x*v2.y, v1.x*v2.x + v1.y*v2.y);
	
	return angle;
}
