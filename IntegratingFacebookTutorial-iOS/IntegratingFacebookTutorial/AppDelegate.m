//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "DrawViewController.h"
#import "MainViewController.h"
#import "RoundStore.h"
#import "GameRound.h"


@implementation AppDelegate


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // ****************************************************************************
    // Fill in with your Parse credentials:
    // ****************************************************************************
     [Parse setApplicationId:@"YJn6jGFThaPfOIyDqUK7tu4FchsJR3nsxr94BCUU" clientKey:@"pXJXHegNUAQTv50YFY1VRyRWfoVlsZNUtOeMnoe0"];

    // ****************************************************************************
    // Your Facebook application id is configured in Info.plist.
    // ****************************************************************************
    [PFFacebookUtils initializeFacebook];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        NSLog(@"hmm");
        // use registerUserNotificationSettings
    } else {
        // use registerForRemoteNotifications
        // Register for push notifications
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }

    // Override point for customization after application launch.
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName: [UIColor whiteColor],                                                           NSFontAttributeName: [UIFont fontWithName:@"Avenir-Book" size:16]}];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName: [UIFont fontWithName:@"Avenir-Book" size:16]
       } forState:UIControlStateNormal];
    return YES;

}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (!userInfo[@"id"]) {
        [PFPush handlePush:userInfo];
    }
    else {
        if ([application applicationState] == UIApplicationStateInactive) {
            self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
        } else {
            self.otherPlayerID = userInfo[@"id"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"Later" otherButtonTitles: @"View now", nil];
            [alert show];
        }
        NSLog(@"uinfo %@ ", userInfo);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        int index = [[RoundStore sharedStore].playerRounds indexOfObject:self.otherPlayerID];
        GameRound *gr = [RoundStore sharedStore].gameRounds[index];
        [RoundStore sharedStore].currentRound = gr;
        UINavigationController *root = (UINavigationController *) self.window.rootViewController;
        [root popToViewController:root.viewControllers[1] animated:YES];
    }
}

-(void) goToCorrectScreen:(NSDictionary *)userInfo {
    NSLog(@"uinfo %@", userInfo);
}

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
} 

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}


@end
