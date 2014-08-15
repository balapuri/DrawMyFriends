//
//  ResultsViewController.m
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/24/14.
//
//

#import "ResultsViewController.h"

#import <Parse/Parse.h>

#import "GameRound.h"
#import "RoundStore.h"

@interface ResultsViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(getPreviousDrawing) name:LoadedPreviousDrawing object:nil];
    GameRound *gr = [RoundStore sharedStore].currentRound;
    if ([gr.currentRound[@"previousGuess"] isEqualToString:gr.currentRound[@"previousSubject"]]) {
        self.resultLabel.text = [NSString stringWithFormat:@"%@ guessed '%@' correctly", gr.currentRound[@"previousGuesser"], gr.currentRound[@"previousSubject"]];
    } else {
        self.resultLabel.text = [NSString stringWithFormat:@"%@ thought '%@' was '%@'", gr.currentRound[@"previousGuesser"], gr.currentRound[@"previousSubject"], gr.currentRound[@"previousGuess"]];
    }
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
}

- (void) getPreviousDrawing {
    GameRound *gr = [RoundStore sharedStore].currentRound;
    [self.spinner stopAnimating];
    NSLog(@"wot");
    self.guessedImage.image = gr.previousDrawing;
    self.guessedImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.guessedImage.layer setShadowOpacity:.8];
    [self.guessedImage.layer setShadowRadius:3.0];
    [self.guessedImage.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareOnFacebook:(id)sender {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            __block NSString *alertText;
                                            __block NSString *alertTitle;
                                            if (!error) {
                                                NSLog(@"facebutt %@", [FBSession.activeSession.permissions[1] class]);
                                                if ([FBSession.activeSession.permissions
                                                     indexOfObject:@"publish_actions"] == NSNotFound){
                                                    // Permission not granted, tell the user we will not publish
                                                    alertTitle = @"Permission not granted";
                                                    alertText = @"Your action will not be published to Facebook.";
//                                                    [[[UIAlertView alloc] initWithTitle:alertTitle
//                                                                                message:alertText
//                                                                               delegate:self
//                                                                      cancelButtonTitle:@"OK!"
//                                                                      otherButtonTitles:nil] show];
                                                    NSLog(@"%@. %@", alertTitle, alertText);
                                                    [self useShareDialog];
                                                } else {
                                                    // Permission granted, publish the OG story
                                                    [self useShareDialog];
                                                }

                                            } else {
                                                NSLog(@"error with permissions: %@", error);
                                                // There was an error, handle it
                                                // See https://developers.facebook.com/docs/ios/errors/
                                            }
                                        }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) useShareDialog {
   GameRound *gr = [RoundStore sharedStore].currentRound;
    
    // Create an object
    id<FBGraphObject> object =
    [FBGraphObject openGraphObjectForPostWithType:@"drawmyfriends:picture"
                                            title:@"Draw My Friends"
                                            image:((PFFile *)gr.currentRound[@"previousImageFile"]).url
                                              url:((PFFile *)gr.currentRound[@"previousImageFile"]).url
                                      description:[NSString stringWithFormat:@"I drew a picture of my friend. Can you guess who it is? %@ did!", gr.currentRound[@"previousGuesser"]]];
    
    // Create an action
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    
    // Link the object to the action
    [action setObject:object forKey:@"picture"];
    [action setTags:@[gr.otherPlayer]];
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBOpenGraphActionShareDialogParams *params = [[FBOpenGraphActionShareDialogParams alloc] init];
    params.action = action;
    params.actionType = @"drawmyfriends:draw";
    
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
        // Show the share dialog
        [FBDialogs presentShareDialogWithOpenGraphAction:action
                                              actionType:@"drawmyfriends:draw"
                                     previewPropertyName:@"picture"
                                                 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                     if(error) {
                                                         // There was an error
                                                         NSLog(@"Error publishing story: %@", error.description);
                                                     } else {
                                                         // Success
                                                         NSLog(@"result %@", results);
                                                     }
                                                 }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK GOES HERE
    }

}

- (IBAction)notNow:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
