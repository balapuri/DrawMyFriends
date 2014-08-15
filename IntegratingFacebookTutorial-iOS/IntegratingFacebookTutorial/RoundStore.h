//
//  RoundStore.h
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/18/14.
//
//

#import <Foundation/Foundation.h>
#import "GameRound.h"

static BOOL loadedRounds;

@interface RoundStore : NSObject

+ (instancetype) sharedStore;
- (GameRound *) makeNewRoundWithPlayer:(NSString *)player1 otherPlayer: (NSString *)player2 playerName: (NSString *) name1 otherName: (NSString *)name2 subjectBeingDrawn:(NSString *) friend;
- (GameRound *) makeNewRoundWithPlayer:(NSString *)player1 otherPlayer: (NSString *)player2 playerName: (NSString *) name1 otherName: (NSString *)name2;
- (GameRound *) checkIfRoundExistsAndSetAsCurrent:(NSString *)otherPlayer;
- (void)checkForNewRounds;

@property (nonatomic, copy) NSMutableArray *gameRounds;
@property (nonatomic, copy) NSMutableArray *playerRounds;
@property (nonatomic, strong) GameRound *currentRound;

@end
