//
//  MainViewController.m
//  DrawMyFriends
//
//  Created by Maya Reddy on 8/1/14.
//
//

#import "MainViewController.h"
#import "RoundStore.h"
#import "GameRound.h"
#import "GameTableViewCell.h"
#import "ResultsViewController.h"
#import "FriendSubjects.h"
#import "GuessViewController.h"
#import "ChooseViewController.h"
#import <Parse/Parse.h>

@interface MainViewController () <FBFriendPickerDelegate, UISearchBarDelegate>

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;

@end

@implementation MainViewController

bool finishedLoadingFriends = NO;

- (instancetype)init {
    self = [super init];
    if (self) {
        _rounds = [RoundStore sharedStore].gameRounds;
        _addGameButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _playButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(refreshData:) name:LoadedRoundsWithCurrentUserAsArtist object:nil];
    }
    return self;
}

- (void) refreshData:(NSNotification *)notification {
    [self.currentGames reloadData];
}

- (void)loadView {
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor blackColor];
    self.view = contentView;
    
    UIImage *logo = [UIImage imageNamed:@"DMFtestlogo2.png" ];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
    logoView.frame=CGRectMake(65, 75, 190, 95);
    logoView.layer.opacity=.95;
    [self.view addSubview:logoView];
    
    self.addGameButton.frame = CGRectMake(10, 200, 300, 25);
    [self.addGameButton addTarget:self action:@selector(addNewGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.addGameButton setTitle:@"+ Add Game" forState:UIControlStateNormal];
    [self.addGameButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:20]];
    [self.addGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addGameButton setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.addGameButton];
    
    self.playButton.frame = CGRectMake(10, 485, 300, 25);
    [self.playButton addTarget:self action:@selector(playGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setTitle:@"Continue Game" forState:UIControlStateNormal];
    [self.playButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:20]];
    [self.playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.playButton setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.playButton];
    
    CGRect tableRect = CGRectMake(40, 235, 240, 240);
    self.currentGames = [[UITableView alloc]initWithFrame:tableRect];
    
    self.currentGames.backgroundView=nil;
    self.currentGames.backgroundColor = [UIColor blackColor];
    self.currentGames.dataSource = self;
    self.currentGames.delegate = self;
    [self.view addSubview:self.currentGames];
    [self.currentGames setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = nil;
    customColorView.layer.borderColor=[UIColor whiteColor].CGColor;
    customColorView.layer.borderWidth=2;
    customColorView.layer.cornerRadius=7;
    cell.selectedBackgroundView =  customColorView;
}


#pragma mark - UIViewController

- (void)didReceiveMemoryWarning {
    self.friendPickerController = nil;
    self.searchBar = nil;
}

#pragma TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"table cell");
    GameTableViewCell *cell = [self.currentGames dequeueReusableCellWithIdentifier:@"GameTableViewCell"];
    if (!cell) {
        cell = [[GameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GameTableViewCell"];
        
    }
    GameRound *gameRound = (GameRound *)self.rounds[indexPath.row];
    cell.name.text = gameRound.otherPlayerName;
    cell.name.textAlignment = NSTextAlignmentCenter;
    [cell.name setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rounds.count;
}

- (void) addNewGame:(UIButton *)button {
    [self loadFriendPicker];
}

- (void) playGame:(UIButton *)button {
    NSIndexPath *indexPath = [self.currentGames indexPathForSelectedRow];
    if (indexPath) {
        GameRound *gr = [[RoundStore sharedStore] gameRounds][indexPath.row];
        [RoundStore sharedStore].currentRound = gr;
        [self startGame:gr];
    }
}

#pragma FriendPicker

- (void)loadFriendPicker {
    if (self.friendPickerController == nil) {
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
        [titleLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:24]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        titleLabel.text = @"Pick Player";
        self.navigationController.navigationItem.titleView = titleLabel;
        NSLog(@"nav item %@", self.navigationController.navigationItem);
        self.friendPickerController.title = @"Pick Friends";
        
        self.friendPickerController.delegate = self;
        self.friendPickerController.allowsMultipleSelection = NO;
        NSSet *fields = [NSSet setWithObjects:@"installed", nil];
        self.friendPickerController.fieldsForRequest = fields;
    }
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    //load the 4 subjects
    
    if ([PFUser currentUser] && [PFUser currentUser][@"DMFFacebookID"]) {
        [RoundStore sharedStore];
        finishedLoadingFriends = YES;
    }
    
        [self.navigationController presentViewController:self.friendPickerController animated:YES completion:^{
            [self addSearchBarToFriendPickerView];
        }];
}

- (void)addSearchBarToFriendPickerView {
    if (self.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        self.searchBar.autoresizingMask = self.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        
        [self.friendPickerController.canvasView addSubview:self.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}

- (void) handleSearch:(UISearchBar *)searchBar {
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    [searchBar resignFirstResponder];
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    [self.friendPickerController updateView];
    
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    if (!user[@"installed"]) {
        return NO;
    }
    
    if (self.searchText && ![self.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:self.searchText
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self handleSearch:searchBar];
}

- (void) handlePickerDone: (FBFriendPickerViewController *)fpc
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    FBFriendPickerViewController *fpc = (FBFriendPickerViewController *)sender;
    if ([fpc.selection count] > 0) {
        NSString *player2 = [NSString stringWithFormat:@"%@", ((id<FBGraphUser>)fpc.selection[0]).id ];
        NSString *name2 = [NSString stringWithFormat:@"%@", ((id<FBGraphUser>)fpc.selection[0]).name ];
        NSString *name1 = [PFUser currentUser][@"name"];
        NSLog(@"p2 %@ name2 %@ name1 %@", player2, name2, name1);
        GameRound *gr = [self makeRoundWithNewOpponent:player2 currentPlayerName:name1 otherPlayerName:name2];
        [self handlePickerDone:fpc];
        [self.currentGames reloadData];
        [self startGame:gr];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Choose a friend to guess your drawing"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    FBFriendPickerViewController *fpc = (FBFriendPickerViewController *)sender;
    [self handlePickerDone:fpc];
}

- (GameRound *)makeRoundWithNewOpponent:(NSString*) player2 currentPlayerName:(NSString *)p1 otherPlayerName:(NSString *)p2 {
    NSLog(@"p %@ %@ %@", player2, p1, p2);
    NSString *player1 = [PFUser currentUser][@"DMFFacebookID"];
    GameRound *gameRound = [[RoundStore sharedStore] makeNewRoundWithPlayer:player1 otherPlayer:player2 playerName:p1 otherName:p2];
    
    return gameRound;
}

- (void)startGame:(GameRound *)gameRound {
    if (gameRound.loadedRound) {
        [gameRound refreshValues];
    }
    [[FriendSubjects sharedFriends] getFriends];
    
    if ([gameRound.currentPlayer isEqualToString:gameRound.currentRound[@"guesser"]]) {
        // guesser has not guessed yet
        if ([gameRound.currentRound[@"guess"] isEqualToString:@""] || (!gameRound.currentRound[@"guess"] && gameRound.currentRound[@"imageFile"])) {
            if (gameRound.currentRound[@"previousGuess"] && ![gameRound.currentRound[@"previousGuesser"] isEqualToString:[PFUser currentUser][@"firstName"]]) {
                NSLog(@"previous guess %@ previous guesser %@ previous subject %@ gameround %@ curr %@", gameRound.currentRound[@"previousGuess"], gameRound.currentRound[@"previousGuesser"], gameRound.currentRound[@"previousSubject"], gameRound, [RoundStore sharedStore].currentRound);
                ResultsViewController *rvc = [[ResultsViewController alloc] init];
                [self presentViewController:rvc animated:YES completion:^{
                    GuessViewController *gvc = [[GuessViewController alloc] init];
                    [self.navigationController pushViewController:gvc animated:YES];
                }];
            } else {
                GuessViewController *gvc = [[GuessViewController alloc] init];
                [self.navigationController pushViewController:gvc animated:YES];
            }
            
        } else if (gameRound.currentRound[@"guess"] && ![gameRound.currentRound[@"guess"] isEqualToString:@""] && ![gameRound.currentRound[@"previousGuesser"] isEqualToString:[PFUser currentUser][@"firstName"]]){
            ResultsViewController *rvc = [[ResultsViewController alloc] init];
            [self presentViewController:rvc animated:YES completion:nil];
//            [self presentViewController:rvc animated:YES completion:^{
//                ChooseViewController *cvc = [[ChooseViewController alloc] init];
//                [self.navigationController pushViewController:cvc animated:YES];
//            }];
        } else {
//            ChooseViewController *cvc = [[ChooseViewController alloc] init];
//            [self.navigationController pushViewController:cvc animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Your friend hasn't sent you a drawing yet"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    } else {
        if ([gameRound.currentRound[@"guess"] isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Your friend hasn't guessed your previous drawing yet"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else if (gameRound.currentRound[@"guess"] && ![gameRound.currentRound[@"previousGuesser"] isEqualToString:[PFUser currentUser][@"firstName"]]){
            ResultsViewController *rvc = [[ResultsViewController alloc] init];
            [self presentViewController:rvc animated:YES completion:^{
                ChooseViewController *cvc = [[ChooseViewController alloc] init];
                [self.navigationController pushViewController:cvc animated:YES];
            }];
            //[self presentViewController:rvc animated:YES completion:nil];
        } else {
            ChooseViewController *cvc = [[ChooseViewController alloc] init];
            [self.navigationController pushViewController:cvc animated:YES];
        }
    }
}
@end
