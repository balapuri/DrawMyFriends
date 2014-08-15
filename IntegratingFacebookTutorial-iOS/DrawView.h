//
//  DrawView.h
//  DrawMyFriends
//
//  Created by Lilly Holymushrooms Shen on 7/15/14.
//
//

#import <UIKit/UIKit.h>
//#import "DrawViewController.h"

@interface DrawView : UIView

@property (nonatomic, readwrite, strong) UIColor *color;
@property (nonatomic) UIColor *previousColor;
@property (nonatomic) CGFloat brush;
@property (nonatomic) CGFloat opacity;
@property (nonatomic, strong) NSMutableArray *drawHistory;
@property (nonatomic) NSInteger index;
- (void)rewind;
- (void)fastForward;
- (void)clear;
- (UIImage *)getDrawing;
@end
