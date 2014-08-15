//
//  ResultsViewController.h
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/24/14.
//
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIImageView *guessedImage;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
- (IBAction)shareOnFacebook:(id)sender;
- (IBAction)notNow:(id)sender;

@end
