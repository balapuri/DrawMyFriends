//
//  GameTableViewCell.h
//  DrawMyFriends
//
//  Created by Maya Reddy on 8/1/14.
//
//

#import <UIKit/UIKit.h>
static const NSString *GameCellIDTitle = @"GameTableViewCell";

@interface GameTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIImageView *profilePic;

@end
