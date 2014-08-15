//
//  MainViewController.h
//  DrawMyFriends
//
//  Created by Maya Reddy on 8/1/14.
//
//

#import <UIKit/UIKit.h>
@class GameRound;

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *currentGames;
@property (nonatomic, strong) UIButton *addGameButton;
@property (nonatomic, strong) NSArray *rounds;
@property (nonatomic, strong) UIButton *playButton;

- (void) refreshData:(NSNotification *) notification;
- (void) addNewGame: (UIButton *)button;
- (void) playGame: (UIButton *)button;
- (void) startGame: (GameRound *)gameRound;

@end
