//
//  FriendSubjects.h
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/17/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@class ChooseViewController;

static int numFriends = 0;
static const int maxNumFriends = 4;

@interface FriendSubjects : NSObject <NSURLConnectionDataDelegate>

+ (instancetype) sharedFriends;
+ (int)getNumFriends;
- (NSArray *) getUrls;
- (NSArray *) getNames;
- (NSArray *) getPhotos;
- (void) getFriends;
- (void) refreshFriends;
//- (void) setChooseViewControllerAsObserver:(NSObject *) object;
@property int whichPic;
@property (nonatomic) NSMutableArray *urlList;
@property (nonatomic) NSMutableArray *nameList;
@property (nonatomic) NSMutableArray *imageList;
@property (nonatomic) NSMutableArray *imageOrderList;
@property (atomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) NSMutableArray *mutualFriends;
@property BOOL usedOnce;

@end
