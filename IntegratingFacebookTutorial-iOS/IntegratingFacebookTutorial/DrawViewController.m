//
//  DrawViewController.m
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/15/14.
//
//

#import "DrawViewController.h"
#import "DrawView.h"
#import "UIImage+Resize.h"
#import <Parse/Parse.h>
#import "RoundStore.h"
#import "GameRound.h"

@interface DrawViewController ()
@property (nonatomic) BOOL eraserOn;
@property (nonatomic) BOOL colorPickerOn;
@property (nonatomic) BOOL sizeSetterOn;
@property (nonatomic,strong) UIImage *firstThumbImage;
@property (nonatomic) UIView *colorSubview;
@property (nonatomic) UIView *sizeSubview;
@end

@implementation DrawViewController
{
    DrawView *drawView;
    void (^hideColorPicker)(void);
    void (^showColorPicker)(void);
    
}

//method for changing color of image

-(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    // load the image
    
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    // paint over in white
    [[UIColor whiteColor] setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to normal, and the original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    // set the fill color
    [color setFill];
    
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

- (IBAction)undoDraw:(id)sender {
    [drawView rewind];
}
- (IBAction)redoDraw:(id)sender {
    [drawView fastForward];
}

- (IBAction)changeBrushSize:(id)sender {
    self.sizeSetterOn= !self.sizeSetterOn;
    UIBarButtonItem *tempBrushSize= sender;
    if(self.sizeSetterOn)
    {
        self.sizeSubview.hidden=false;
        self.sizeSlider.hidden=false;
        //set other pickers to off
        self.colorPickerOn=false;
        if(self.eraserOn)
            drawView.color=drawView.previousColor;
        self.eraserOn=false;
        CGFloat diameter= self.sizeSlider.value;
        CGSize size = CGSizeMake (diameter, diameter);
        [self.sizeSlider setThumbImage:[UIImage_Resize imageWithImage: self.firstThumbImage scaledToSize: size] forState:UIControlStateNormal];
        
        //set tint colors
        self.eraser.tintColor=[UIColor blackColor];
        tempBrushSize.tintColor=[UIColor grayColor];
        self.colorPicker.tintColor=[UIColor blackColor];
        hideColorPicker();
    }
    else
    {
        self.sizeSubview.hidden=true;
        self.sizeSlider.hidden=true;
        
        //set tint color
        tempBrushSize.tintColor=[UIColor blackColor];
    }
}


- (IBAction)clearCanvas:(id)sender {
    [drawView clear];
}


- (IBAction)setBrushSize:(id)sender {
    UISlider *slider= sender;
    if(drawView)
    {
        drawView.brush= slider.value;
        CGFloat diameter= self.sizeSlider.value;
        CGSize size = CGSizeMake (diameter, diameter);
        [sender setThumbImage:[UIImage_Resize imageWithImage: self.firstThumbImage scaledToSize: size] forState:UIControlStateNormal];

    }
    
}
- (IBAction)changeOpacity:(id)sender {
    UISlider *slider = sender;
    drawView.opacity=slider.value;
    drawView.color= [drawView.color colorWithAlphaComponent:slider.value];
    self.firstThumbImage=[self imageNamed:@"circle.png" withColor:drawView.color];
    CGFloat diameter= self.sizeSlider.value;
    CGSize size = CGSizeMake (diameter, diameter);
    [slider setThumbImage:[UIImage_Resize imageWithImage: self.firstThumbImage scaledToSize: size] forState:UIControlStateNormal];
}

- (IBAction)eraserPressed: (id)sender{
    self.eraserOn= !(self.eraserOn);
    UIBarButtonItem *tempEraser= sender;
    if(self.eraserOn)
    {
        //set other pickers to off
        self.colorPickerOn=false;
        self.sizeSetterOn=false;
        
        hideColorPicker();
        self.sizeSubview.hidden=true;
        self.sizeSlider.hidden=true;
        drawView.previousColor= drawView.color;
        drawView.color=[UIColor whiteColor];
        
        //set tint colors
        tempEraser.tintColor=[UIColor grayColor];
        self.brushSize.tintColor=[UIColor blackColor];
        self.colorPicker.tintColor=[UIColor blackColor];
    }
    else
    {
        drawView.color=drawView.previousColor;
        tempEraser.tintColor=[UIColor blackColor];
    }
}

-(void)loadView
{
    __weak typeof(self) weakSelf = self;
    hideColorPicker = ^void {
        weakSelf.skin1.hidden=true;
        weakSelf.skin2.hidden=true;
        weakSelf.skin3.hidden=true;
        weakSelf.skin4.hidden=true;
        weakSelf.skin5.hidden=true;
        weakSelf.skin6.hidden=true;
        weakSelf.skin7.hidden=true;
        weakSelf.skin8.hidden=true;
        weakSelf.color1.hidden=true;
        weakSelf.color2.hidden=true;
        weakSelf.color3.hidden=true;
        weakSelf.color4.hidden=true;
        weakSelf.color5.hidden=true;
        weakSelf.color6.hidden=true;
        weakSelf.color7.hidden=true;
        weakSelf.color8.hidden=true;
        weakSelf.opacitySlider.hidden=true;
        weakSelf.colorSubview.hidden=true;
        
    };
    showColorPicker = ^void {
       
       
        weakSelf.skin1.hidden=false;
        weakSelf.skin2.hidden=false;
        weakSelf.skin3.hidden=false;
        weakSelf.skin4.hidden=false;
        weakSelf.skin5.hidden=false;
        weakSelf.skin6.hidden=false;
        weakSelf.skin7.hidden=false;
        weakSelf.skin8.hidden=false;
        weakSelf.color1.hidden=false;
        weakSelf.color2.hidden=false;
        weakSelf.color3.hidden=false;
        weakSelf.color4.hidden=false;
        weakSelf.color5.hidden=false;
        weakSelf.color6.hidden=false;
        weakSelf.color7.hidden=false;
        weakSelf.color8.hidden=false;
        weakSelf.opacitySlider.hidden=false;
        weakSelf.colorSubview.hidden=false;
    };
}

- (void)viewDidLoad
{
//    GameRound *gr = [RoundStore sharedStore].currentRound;
//    if (gr.currentRound[@"guess"]) {
//        [gr storePreviousValues];
//    }

    NSArray * allTheViewsInMyNIB = [[NSBundle mainBundle] loadNibNamed:@"DrawViewController" owner:self options:nil]; // loading nib (might contain more than one view)
    
    self.view=allTheViewsInMyNIB[0];
    
//NSLog(@"%f", self.view.frame.size.width);
    //go back and unhardcode this part
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGRect subframe = CGRectMake(20, 90, 280, .7*screenHeight);
    DrawView *subview = [[DrawView alloc] initWithFrame:subframe];
    
    [subview.layer setShadowColor:[UIColor blackColor].CGColor];
    [subview.layer setShadowOpacity:0.8];
    [subview.layer setShadowRadius:3.0];
    [subview.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    
    [self.view addSubview:subview];
    drawView=subview;
    
    
    self.eraserOn = false;
    self.colorPickerOn=false;
    self.sizeSetterOn=false;
    
    self.sizeSlider.hidden=true;
    self.sizeSlider.tintColor=[UIColor grayColor];
    self.firstThumbImage=[self imageNamed:@"circle.png" withColor:drawView.color];
    
    [self.sizeSlider setMinimumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    [self.sizeSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    [self.opacitySlider setMinimumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    [self.opacitySlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    
    drawView.previousColor=[[UIColor blackColor] colorWithAlphaComponent:.5];
    
    //subview under color swatches and opacity slider
    CGRect colorSubframe = CGRectMake(3, .67*screenHeight, screenWidth-6, .33*screenHeight);
    self.colorSubview = [[UIView alloc] initWithFrame:colorSubframe];
    [self.colorSubview.layer setBackgroundColor:[UIColor colorWithRed:.9 green:.9 blue:.92 alpha:.90].CGColor];
    [self.colorSubview.layer setCornerRadius:5];
    [self.view addSubview:self.colorSubview];
    
    //give swatches rounded corners
    [self.color1.layer setCornerRadius:3];
    [self.color2.layer setCornerRadius:3];
    [self.color3.layer setCornerRadius:3];
    [self.color4.layer setCornerRadius:3];
    [self.color5.layer setCornerRadius:3];
    [self.color6.layer setCornerRadius:3];
    [self.color7.layer setCornerRadius:3];
    [self.color8.layer setCornerRadius:3];
    [self.skin1.layer setCornerRadius:3];
    [self.skin2.layer setCornerRadius:3];
    [self.skin3.layer setCornerRadius:3];
    [self.skin4.layer setCornerRadius:3];
    [self.skin5.layer setCornerRadius:3];
    [self.skin6.layer setCornerRadius:3];
    [self.skin7.layer setCornerRadius:3];
    [self.skin8.layer setCornerRadius:3];

    
    //subview under size slider
    CGRect sizeSubframe = CGRectMake(3, .8*screenHeight, screenWidth-6, .2*screenHeight);
    self.sizeSubview = [[UIView alloc] initWithFrame:sizeSubframe];
    [self.sizeSubview.layer setBackgroundColor:[UIColor colorWithRed:.9 green:.9 blue:.92 alpha:.90].CGColor];
    [self.sizeSubview.layer setCornerRadius:5];
    [self.view addSubview:self.sizeSubview];
    self.sizeSubview.hidden=true;
    
    //order subviews
    
    [self.view sendSubviewToBack:self.colorSubview];
    [self.view sendSubviewToBack:self.sizeSubview];
    [self.view sendSubviewToBack:subview];
    
    hideColorPicker();
    
}


- (IBAction)pickerPopsUp:(id)sender {
    self.colorPickerOn= !(self.colorPickerOn);
    
    if (self.colorPickerOn) {

        if (self.eraserOn) {
            drawView.color=drawView.previousColor;
        }
        CGFloat diameter= self.sizeSlider.value;
        CGSize size = CGSizeMake (diameter, diameter);
        [self.opacitySlider setThumbImage:[UIImage_Resize imageWithImage: self.firstThumbImage scaledToSize: size] forState:UIControlStateNormal];
        showColorPicker();
        
        self.sizeSlider.hidden=true;
        self.sizeSubview.hidden=true;
        
        self.eraserOn=false;
        self.sizeSetterOn=false;
        
        //set tint colors
        self.eraser.tintColor=[UIColor blackColor];
        self.brushSize.tintColor=[UIColor blackColor];
        self.colorPicker.tintColor=[UIColor grayColor];
    }
    else{
        hideColorPicker();
        
        //set tint color
        self.colorPicker.tintColor=[UIColor blackColor];
    }
}


- (IBAction)colorSelected:(id)sender
{
    
    UIButton *buttonSelected = sender;
    UIColor *colorSelected = buttonSelected.backgroundColor;
    if(colorSelected != drawView.color){
        drawView.previousColor=drawView.color;
        drawView.color = [colorSelected colorWithAlphaComponent:drawView.opacity];
        self.firstThumbImage=[self imageNamed:@"circle.png" withColor:drawView.color];
        CGFloat diameter= self.sizeSlider.value;
        CGSize size = CGSizeMake (diameter, diameter);
        [self.opacitySlider setThumbImage:[UIImage_Resize imageWithImage: self.firstThumbImage scaledToSize: size] forState:UIControlStateNormal];
        
    }
}


- (void) uploadImage: (NSData *) imageData {
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    //HUD creation here (see example for code)
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hide old HUD, show completed HUD (see example for code)
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *userPhoto = [RoundStore sharedStore].currentRound.currentRound;
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            
            // Set the access control list to current user for security purposes
            //userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            [userPhoto saveInBackground];
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
    }];
}

- (void) continueGame{
    GameRound *gr = [RoundStore sharedStore].currentRound;
    [gr makeCurrentPlayerArtistAndClearGuess];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Your drawing has been sent!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    // should probably also have this in GuessViewController
    [[RoundStore sharedStore] checkForNewRounds];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popToViewController:[self.navigationController viewControllers][1] animated:YES];
}

- (IBAction)submitPicture:(id)sender {
    UIImage *image = [drawView getDrawing];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.05f);
    
    GameRound *gr = [RoundStore sharedStore].currentRound;
    NSDictionary *data = @{@"id":gr.currentPlayer, @"alert":[NSString stringWithFormat:@"%@ sent you a drawing.", [PFUser currentUser][@"firstName"]]};
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:[NSString stringWithFormat:@"from%@to%@", gr.currentPlayer, gr.otherPlayer]];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"%hhd did succeed", succeeded);
    }];

    
    [self uploadImage:imageData];
    [self continueGame];
}
@end
