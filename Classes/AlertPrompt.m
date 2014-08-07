//
//  AlertPrompt.m
//  MBP_ios
//
//  @credit:
//  http://iphonedevelopment.blogspot.sg/2009/02/alert-view-with-prompt.html
//

#import "AlertPrompt.h"

@implementation AlertPrompt

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
       promptholder:(NSString *)placeHolder
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okayButtonTitle
{
    if (self = [super initWithTitle:title message:@"\n\n"
                           delegate:delegate
                  cancelButtonTitle:cancelButtonTitle
                  otherButtonTitles:okayButtonTitle, nil])
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        theTextField.borderStyle = UITextBorderStyleRoundedRect;
        [theTextField setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:theTextField];
        self.textField = theTextField;
        self.textField.placeholder = placeHolder;
    }
    return self;
}

- (void)layoutSubviews_not_used
{
    for (UIView *subview in self.subviews) {
        if ( ![subview isMemberOfClass:[UIImageView class]] &&
            ![subview isMemberOfClass:[UILabel class]] &&
            ![subview isMemberOfClass:[UITextField class]])
        {
            // Must be those damn Button
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
    [_textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText
{
    return _textField.text;
}

@end