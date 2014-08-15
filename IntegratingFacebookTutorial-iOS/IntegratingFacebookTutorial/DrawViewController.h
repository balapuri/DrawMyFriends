//
//  DrawViewController.h
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/15/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DrawView.h"

@interface DrawViewController : UIViewController <UIAlertViewDelegate>



//@property (nonatomic, retain) id labelCellNib;

@property (weak, nonatomic) IBOutlet UIButton *skin1;
@property (weak, nonatomic) IBOutlet UIButton *skin2;
@property (weak, nonatomic) IBOutlet UIButton *skin3;
@property (weak, nonatomic) IBOutlet UIButton *skin4;
@property (weak, nonatomic) IBOutlet UIButton *skin5;
@property (weak, nonatomic) IBOutlet UIButton *skin6;
@property (weak, nonatomic) IBOutlet UIButton *skin7;
@property (weak, nonatomic) IBOutlet UIButton *skin8;

@property (weak, nonatomic) IBOutlet UIButton *color1;
@property (weak, nonatomic) IBOutlet UIButton *color2;
@property (weak, nonatomic) IBOutlet UIButton *color3;
@property (weak, nonatomic) IBOutlet UIButton *color4;
@property (weak, nonatomic) IBOutlet UIButton *color5;
@property (weak, nonatomic) IBOutlet UIButton *color6;
@property (weak, nonatomic) IBOutlet UIButton *color7;
@property (weak, nonatomic) IBOutlet UIButton *color8;



@property (weak, nonatomic) IBOutlet UIToolbar *drawBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *eraser;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *colorPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *brushSize;
@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;
@property (nonatomic) CGSize currentBrushSize;


- (IBAction)submitPicture:(id)sender;


//@interface DrawViewController : UIViewController <UIAlertViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end
