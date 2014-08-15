//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "ChooseViewController.h"
#import "FriendSubjects.h"
#import "GameRound.h"
#import "RoundStore.h"
#import "GuessViewController.h"
#import "ResultsViewController.h"
#import "MainView.h"
#import "MainViewController.h"
#import "InfoViewController.h"

@interface LoginViewController () <FBFriendPickerDelegate, UISearchBarDelegate>
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;

@end

@implementation LoginViewController

bool loadedFriends = NO;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Facebook Profile";
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // Create a cache descriptor based on the default friend picker data fetch settings
        FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
        // Pre-fetch and cache friend data
        [cacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
        [self goToMainView];
    }
}

- (void)goToMainView {
    MainViewController *mvc = [[MainViewController alloc] init];
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonTouchHandler:)];
    mvc.navigationItem.leftBarButtonItem = logoutButton;
    UIFont * font = [UIFont fontWithName:@"Avenir-Book" size:16];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [logoutButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(goToInfoPage:)];
    mvc.navigationItem.rightBarButtonItem=infoButton;
    [infoButton setTitleTextAttributes:attributes forState:UIControlStateNormal];

    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)viewDidUnload {
    self.friendPickerController = nil;
    self.searchBar = nil;
}

#pragma mark - Login methods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_friends", ];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        // Store the current user's Facebook ID on the user
                        [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                                 forKey:@"fbId"];
                        [self addFacebookIdColumn];
                    }
                }];
                
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self addFacebookIdColumn];
        } else {
            NSLog(@"User with facebook logged in!");
            [self goToMainView];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void)goToInfoPage:(id)sender {
    InfoViewController *ivc = [[InfoViewController alloc] init];
    UINavigationController *infoNavController =  [[UINavigationController alloc]initWithRootViewController:ivc];
    infoNavController.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentViewController:infoNavController animated:YES completion:NULL];
}

- (void)addFacebookIdColumn {
    [FBRequestConnection startWithGraphPath:@"/me/?fields=id,first_name,name"

                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {
                                  NSLog(@"error...%@", error);
                              }
                              NSLog(@"fid %@", result[@"id"]);
                              [[PFUser currentUser] setValue:result[@"id"] forKey:@"DMFFacebookID"];
                              [[PFUser currentUser] setValue:result[@"first_name"] forKey:@"firstName"];
                              [[PFUser currentUser] setValue:result[@"name"] forKey:@"name"];

                              [[PFUser currentUser] saveInBackground];
                              [self goToMainView];
                                  if (!loadedFriends) {
                                      [RoundStore sharedStore];
                                  }

                              
                          }];
}


#pragma mark - ()

- (void)logoutButtonTouchHandler:(id)sender {
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
