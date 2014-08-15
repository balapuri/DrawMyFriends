//
//  GuessViewController.h
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/22/14.
//
//

#import <UIKit/UIKit.h>

#import <Parse/Parse.h>

@interface GuessViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate,FBFriendPickerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *receivedDrawing;
@property (weak, nonatomic) IBOutlet UITextField *guess;
@property (weak, nonatomic) IBOutlet UIButton *notNowButton;
@property (weak, nonatomic) IBOutlet UIButton *sendDrawingButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end
