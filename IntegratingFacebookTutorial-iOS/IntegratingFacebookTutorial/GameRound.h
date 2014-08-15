//
//  GameRound.h
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/18/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

static  NSString *LoadedRoundsWithCurrentUserAsArtist = @"LoadedRoundsWithCurrentUserAsArtist";
static  NSString *LoadedMutualFriends = @"LoadedMutualFriends";
static  NSString *LoadedMutualFriendsPictures = @"LoadedMutualFriendsPictures";
static  NSString *LoadedPreviousDrawing = @"LoadedPreviousDrawing";
static NSString *LoadedCurrentDrawing = @"LoadedCurrentDrawing";

@interface GameRound : NSObject

@property (nonatomic, strong) NSString *currentPlayer;
@property (nonatomic, strong) NSString *otherPlayer;
@property (nonatomic, strong) PFObject *currentRound;
@property (nonatomic, strong) NSString *subjectBeingDrawn;
@property (nonatomic, strong) NSString *guess;
@property (nonatomic, strong) NSString *guesser;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) UIImage *drawing;
@property (nonatomic, strong) UIImage *previousDrawing;
@property (nonatomic, strong) NSString *currentPlayerName;
@property (nonatomic, strong) NSString *otherPlayerName;
@property int roundOrder;
@property BOOL loadedRound;
@property BOOL imageIsLoaded;

- (instancetype) initWithPlayer: (NSString *)player1 otherPlayer:(NSString *)player2 playerName: (NSString *) name1 otherName: (NSString *)name2 currentPlayerIsArtist: (BOOL) isArtist order: (int)num;
- (instancetype) initWithPlayer: (NSString *)player1 otherPlayer:(NSString *)player2 playerName: (NSString *) name1 otherName: (NSString *)name2 currentPlayerIsArtist: (BOOL) isArtist subjectBeingDrawn:(NSString *)friend order: (int)num;
- (instancetype) initWithRound:(PFObject *)existingRound currentPlayerIsArtist: (BOOL) isArtist order: (int)num;
- (void)makeCurrentPlayerArtist;
- (void)makeOtherPlayerArtist;
- (void)clearGuess;
- (void)refreshValues;
- (void)storePreviousValues;
- (void)makeCurrentPlayerArtistAndClearGuess;

@end

