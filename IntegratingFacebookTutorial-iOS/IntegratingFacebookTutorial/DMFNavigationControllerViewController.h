//
//  DMFNavigationControllerViewController.h
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/15/14.
//
//

#import <UIKit/UIKit.h>

@interface DMFNavigationControllerViewController : UINavigationController <UINavigationControllerDelegate>

@property (nonatomic,copy) dispatch_block_t completionBlock;

@end
