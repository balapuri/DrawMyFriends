//
//  ChooseViewController.m
//  StoryTeller
//
//  Created by Maya Reddy on 7/16/14.
//
//

#import "ChooseViewController.h"
#import <Parse/Parse.h>
#import "FriendSubjects.h"
#import "DrawViewController.h"
#import "RoundStore.h"
#import "GameRound.h"

@interface ChooseViewController ()
@property (copy, nonatomic) NSMutableArray *urlList;
@property (nonatomic, copy) NSMutableArray *nameList;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation ChooseViewController


-(void)viewDidLoad {
    [super viewDidLoad];
    [self.playButton.layer setCornerRadius:5];
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStuff) name:LoadedMutualFriends object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStuff) name:LoadedMutualFriendsPictures object:nil];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return self;
}

- (void)reloadStuff {
    NSLog(@"numf %d", numFriends);
    if ([self.activityIndicator isAnimating]) {
        [self.activityIndicator stopAnimating];
    }
    [self.friendTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.friendTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.activityIndicator startAnimating];
    [FriendSubjects sharedFriends];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma table view data

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numpic %d", numFriends);
    return [FriendSubjects getNumFriends];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 50.7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *name = [[FriendSubjects sharedFriends] getNames][indexPath.row];
    NSLog(@"name %@", name);
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    [cell setBackgroundColor:[UIColor clearColor]];
//    UIView *customColorView = [[UIView alloc] init];
//    customColorView.backgroundColor = nil;
//    customColorView.layer.borderColor=[UIColor blackColor].CGColor;
//    customColorView.layer.borderWidth=4;
//    customColorView.layer.cornerRadius=7;
//    cell.selectedBackgroundView =  customColorView;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIImage *image;
    
    cell.textLabel.text = name;
    cell.textLabel.font= [UIFont fontWithName:@"Avenir-Book" size:20];
    NSArray *pics = [[FriendSubjects sharedFriends] getPhotos];
    NSLog(@"imageList %@", pics);
    if (pics && pics.count > 0 && pics[indexPath.row] != [NSNull null]) {
        image = pics[indexPath.row];
    } else {
        image = [UIImage imageNamed:@"default_avatar.png"];
    }
    
    cell.imageView.image=image;
    CGSize itemSize = CGSizeMake(44, 44);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.3, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    cell.imageView.layer.cornerRadius = 8.0f;
    cell.imageView.layer.masksToBounds = YES;
    UIGraphicsEndImageContext();

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GameRound *gr = [[RoundStore sharedStore] currentRound];
    NSString *name = [[FriendSubjects sharedFriends] getNames][indexPath.row];
    if (!name) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Sorry, there was an error in getting your friends' names."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        gr.currentRound[@"subject"] = name;
        NSLog(@"subject %@ same? %@", gr.currentRound[@"subject"], [[FriendSubjects sharedFriends] getNames][indexPath.row]);
        gr.guess = [[FriendSubjects sharedFriends] getNames][indexPath.row];
    }
}

- (IBAction)playGame:(id)sender {
    if (self.friendTableView.indexPathForSelectedRow) {
        DrawViewController *dvc = [[DrawViewController alloc] init];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:dvc animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Choose a subject to draw"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
