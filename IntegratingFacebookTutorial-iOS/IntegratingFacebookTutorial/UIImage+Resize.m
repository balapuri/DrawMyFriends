//
//  UIImage+Resize.m
//  DrawMyFriends
//
//  Created by Lilly Holymushrooms Shen on 7/22/14.
//
//

#import "UIImage+Resize.h"

@implementation UIImage_Resize

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    CGRect rect=CGRectMake(0, 0, newSize.width, newSize.height);
    [image drawInRect:rect];
//    [color setFill];
//    UIRectFill(rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
