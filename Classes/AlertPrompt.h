//
//  AlertPrompt.h
//  MBP_ios
//
//  @credit:
//  http://iphonedevelopment.blogspot.sg/2009/02/alert-view-with-prompt.html
//

#import <UIKit/UIKit.h>

@interface AlertPrompt : UIAlertView

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy, readonly) NSString *enteredText;
@property (nonatomic, copy) NSString *otherInfo;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
       promptholder:(NSString *)placeHolder
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okayButtonTitle;

@end
