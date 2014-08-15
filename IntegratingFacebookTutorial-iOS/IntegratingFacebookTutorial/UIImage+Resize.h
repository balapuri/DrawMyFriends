//
//  UIImage+Resize.h
//  DrawMyFriends
//
//  Created by Lilly Holymushrooms Shen on 7/22/14.
//
//

#import <Foundation/Foundation.h>

@interface UIImage_Resize : NSObject
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
