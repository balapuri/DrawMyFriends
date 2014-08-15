//
//  InfoViewController.m
//  DrawMyFriends
//
//  Created by Lilly Holymushrooms Shen on 8/8/14.
//
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGRect frame= CGRectMake(35, 15, screenWidth-60, screenHeight);
    self.view= [[UIView alloc] initWithFrame:screenRect];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
    UIFont * font = [UIFont fontWithName:@"Avenir-Book" size:16];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [doneButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem=doneButton;
    
    
    UITextView *infoParagraph = [[UITextView alloc]initWithFrame:frame];
    infoParagraph.text=@"    Draw My Friends is a social drawing game that challenges a player's artistic and interpretive skills. The game starts with one player sending a drawing of a mutual friend of the two players.  The second player guesses the identity of the drawn friend and sends a drawing of another mutual friend. Players also have the option of sharing drawings on Facebook. \n\n     Our current version is in zen mode; the game goes on indefinitely without a scoring system.  In the future, we may implement a more competitive structure with a set number of rounds.  As for now, we hope you enjoy playing our game!";
    infoParagraph.textColor=[UIColor whiteColor];
    //[infoParagraph setFont:[UIFont systemFontOfSize:16]];
    [infoParagraph setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
    infoParagraph.backgroundColor=[UIColor blackColor];
    self.view.backgroundColor=[UIColor blackColor];
    [self.view addSubview:infoParagraph];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
