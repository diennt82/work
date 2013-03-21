//
//  AlertPrompt.h
//  MBP_ios
//
//  @credit:
//  http://iphonedevelopment.blogspot.sg/2009/02/alert-view-with-prompt.html
//

#import <UIKit/UIKit.h>


@interface AlertPrompt : UIAlertView
{
    UITextField *textField;
    NSString * otherInfo; 
}
@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;
@property (nonatomic, retain) NSString * otherInfo;

-(id) initWithTitle:(NSString *)title
              message:(NSString *)message
         promptholder:(NSString *) placeHolder
             delegate:(id)delegate
    cancelButtonTitle:(NSString *)cancelButtonTitle
        okButtonTitle:(NSString *)okayButtonTitle;
@end
