//
//  GuessViewController.m
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/22/14.
//
//

#import "GuessViewController.h"
#import "RoundStore.h"
#import "GameRound.h"
#import "FriendSubjects.h"
#import "ChooseViewController.h"
#import "HTAutocompleteTextField.h"

@interface GuessViewController ()

@property (atomic, assign) BOOL sendDrawing;
@property (nonatomic, strong) FBFriendPickerViewController *fpc;
@end

@implementation GuessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(setDrawing) name:LoadedCurrentDrawing object:nil];
    
    self.guess.delegate = self;
    [self.submitButton.layer setCornerRadius:5];
    [self.notNowButton.layer setCornerRadius:5];
    [self.sendDrawingButton.layer setCornerRadius:5];
   
    [[FriendSubjects sharedFriends] refreshFriends];
    [self setDrawing];
}

- (void) setDrawing {
    GameRound *gr = [RoundStore sharedStore].currentRound;
    self.receivedDrawing.image = gr.drawing;
    self.receivedDrawing.contentMode = UIViewContentModeScaleAspectFit;
    [self.receivedDrawing.layer setShadowOpacity:.8];
    [self.receivedDrawing.layer setShadowRadius:3.0];
    [self.receivedDrawing.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.fpc = nil;
    // Dispose of any resources that can be recreated.
}
- (IBAction)submitGuess:(id)sender {
    self.submitButton.enabled = NO;
    [self.guess resignFirstResponder];
    GameRound *gr = [RoundStore sharedStore].currentRound;
    gr.currentRound[@"guess"] = self.guess.text;
    [gr storePreviousValues];
    if ([self.guess.text isEqualToString:gr.currentRound[@"subject"]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Correct!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:@"Nope! The actual answer: %@", gr.currentRound[@"subject"]]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    self.notNowButton.enabled = YES;
    self.sendDrawingButton.enabled = YES;
    self.notNowButton.hidden = NO;
    self.sendDrawingButton.hidden = NO;
    self.submitButton.hidden = YES;
    self.guess.hidden = YES;
    
    PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = @{@"id":gr.currentPlayer, @"alert":[NSString stringWithFormat:@"%@ guessed your drawing.", [PFUser currentUser][@"firstName"]]};
    [push setChannel:[NSString stringWithFormat:@"from%@to%@", gr.currentPlayer, gr.otherPlayer]];
    [push setData:data];
    [push sendPushInBackground];
    [gr makeCurrentPlayerArtist];
}
- (IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.guess isFirstResponder] && [touch view] != self.guess) {
        [self.guess resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void) switchTurns {
    if (self.sendDrawing) {
        GameRound *gr = [RoundStore sharedStore].currentRound;
        [gr makeCurrentPlayerArtist];
        [[FriendSubjects sharedFriends] refreshFriends];
        
        ChooseViewController *cvc = [[ChooseViewController alloc] init];
        
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController pushViewController:cvc animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (IBAction)sendNewDrawing:(id)sender {
    ChooseViewController *cvc = [[ChooseViewController alloc] init];
    
    UINavigationController *navController = self.navigationController;
    
    [navController popViewControllerAnimated:NO];
    [navController pushViewController:cvc animated:YES];
}
- (IBAction)goBackToFriendPicker:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) displayContentController
{
    if (!_fpc) {
        _fpc = [[FBFriendPickerViewController alloc]init];
        self.fpc.allowsMultipleSelection = NO;
        self.fpc.delegate = self;
        [self.fpc loadData];
        [self.fpc clearSelection];
    }

    [self addChildViewController:self.fpc];
    self.fpc.view.frame = CGRectMake(10, 150, 300, 203);
    [self.view addSubview:self.fpc.view];
    [self.fpc didMoveToParentViewController:self];
}

- (void) hideContentController
{
    [self.fpc willMoveToParentViewController:nil];
    [self.fpc.view removeFromSuperview];
    [self.fpc removeFromParentViewController];
}

#pragma TextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideContentController];
}
- (IBAction)beganEditing:(id)sender {
    [self displayContentController];
}

- (IBAction)textEditingDidChange:(id)sender {
    [self.fpc updateView];
}

#pragma Friend Picker Delegate

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user {
    if (self.guess.text && ![self.guess.text isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:self.guess.text
                          options:NSCaseInsensitiveSearch];
        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}

- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
    // add name to text field
    NSString *name = [NSString stringWithFormat:@"%@", ((id<FBGraphUser>)friendPicker.selection[0]).name];
    self.guess.text = name;
}

@end
