//
//  AlertPrompt.m
//  MBP_ios
//
//  @credit:
//  http://iphonedevelopment.blogspot.sg/2009/02/alert-view-with-prompt.html
//

#import "AlertPrompt.h"

@implementation AlertPrompt
@synthesize textField;
@synthesize otherInfo;

@synthesize enteredText;


- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
       promptholder:(NSString *) placeHolder
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okayButtonTitle
{
    
    if (self = [super initWithTitle:title message:@"\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        theTextField.borderStyle = UITextBorderStyleRoundedRect;
        [theTextField setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:theTextField];
        self.textField = theTextField;
        self.textField.placeholder = placeHolder;
        [theTextField release];
        //CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0);
        //[self setTransform:translate];
        
        
        
        //[self layoutSubviews_];
    }
    return self;
}

- (void)layoutSubviews_not_used
{

    
    for (UIView *subview in self.subviews){ //Fast Enumeration
        //NSLog(@"Found view:%@", [subview class]);
        if ([subview isMemberOfClass:[UIImageView class]]) {
            //subview.hidden = YES; //Hide UIImageView Containing Blue Background
        }
        else if ([subview isMemberOfClass:[UILabel class]]) { //Point to UILabels To Change Text
//            UILabel *label = (UILabel*)subview; //Cast From UIView to UILabel
//            label.textColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
//            label.shadowColor = [UIColor blackColor];
//            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        }
        else if ([subview isMemberOfClass:[UITextField class]])
        {
            //Do nothing
        }
        else //Must be those damn Button
        {
            NSLog(@"Translate. view:%@", [subview class]);
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 20.0);
            [subview setTransform:translate];
            
            
        }
        
    }
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height + 20);
}



- (void)show
{
    [textField becomeFirstResponder];
    [super show];
}
- (NSString *)enteredText
{
    return textField.text;
}
- (void)dealloc
{
    [textField release];
    [super dealloc];
}
@end