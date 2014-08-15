//
//  GameTableViewCell.m
//  DrawMyFriends
//
//  Created by Maya Reddy on 8/1/14.
//
//

#import "GameTableViewCell.h"

@implementation GameTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 40)];
        [_name setTextColor:[UIColor whiteColor]];
        [_name setBackgroundColor:[UIColor clearColor]];
        [_name setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_name];
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
