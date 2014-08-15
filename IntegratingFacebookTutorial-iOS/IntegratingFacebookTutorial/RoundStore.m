//
//  RoundStore.m
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/18/14.
//
//

#import "RoundStore.h"
#import "GameRound.h"

@implementation RoundStore

+ (instancetype)sharedStore {
    static RoundStore *sharedRoundStore;
    
    if (!sharedRoundStore) {
        sharedRoundStore = [[self alloc] initPrivate];
    }
    return sharedRoundStore;
}

- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[FriendSubjects gameRound]"];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _gameRounds = [[NSMutableArray alloc] init];
        _playerRounds = [[NSMutableArray alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        PFInstallation *curr = [PFInstallation currentInstallation];
        NSArray *channels = [curr channels];
        NSLog(@"channels %@", channels);
        
        PFQuery *queryArtist = [PFQuery queryWithClassName:@"Round"];

        [queryArtist whereKey:@"artist" equalTo:[PFUser currentUser][@"DMFFacebookID"]];
        [queryArtist findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d rounds from database.", objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    GameRound *gr = [[GameRound alloc] initWithRound:object currentPlayerIsArtist:YES order:_gameRounds.count];
                    [_gameRounds addObject:gr];
                    [_playerRounds addObject:object[@"guesser"]];
                    
                    NSString *channel = [NSString stringWithFormat:@"from%@to%@", gr.otherPlayer, gr.currentPlayer];
                    if (!channels || ![channels containsObject:channel]) {
                        [curr addUniqueObject:channel forKey:@"channels"];
                        [curr saveInBackground];
                    }
                }
                [nc postNotificationName:LoadedRoundsWithCurrentUserAsArtist object:nil];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        PFQuery *queryGuesser = [PFQuery queryWithClassName:@"Round"];
        [queryGuesser whereKey:@"guesser" equalTo:[PFUser currentUser][@"DMFFacebookID"]];
        [queryGuesser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d rounds from database.", objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    GameRound *gr = [[GameRound alloc] initWithRound:object currentPlayerIsArtist:NO order:_gameRounds.count];
                    [_gameRounds addObject:gr];
                    [_playerRounds addObject:object[@"artist"]];
                    
                    NSString *channel = [NSString stringWithFormat:@"from%@to%@", gr.otherPlayer, gr.currentPlayer];
                    if (!channels || ![channels containsObject:channel]) {
                        [curr addUniqueObject:channel forKey:@"channels"];
                        [curr saveInBackground];
                    }
                }
                [nc postNotificationName:LoadedRoundsWithCurrentUserAsArtist object:nil];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            NSLog(@"updated channels %@", [[PFInstallation currentInstallation] channels]);
        }];
    }
    return self;
}

- (void) checkForNewRounds {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    PFInstallation *curr = [PFInstallation currentInstallation];
    NSArray *channels = [curr channels];
    
    PFQuery *queryGuesser = [PFQuery queryWithClassName:@"Round"];
    [queryGuesser whereKey:@"guesser" equalTo:[PFUser currentUser][@"DMFFacebookID"]];
    [queryGuesser whereKey:@"artist" notContainedIn:self.playerRounds];
    [queryGuesser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d rounds from database.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                if (![self.playerRounds containsObject:object[@"artist"]]) {
                    GameRound *gr = [[GameRound alloc] initWithRound:object currentPlayerIsArtist:NO order:_gameRounds.count];
                    [_gameRounds addObject:gr];
                    [_playerRounds addObject:object[@"artist"]];
                    
                    NSString *channel = [NSString stringWithFormat:@"from%@to%@", gr.otherPlayer, gr.currentPlayer];
                    if (!channels || ![channels containsObject:channel]) {
                        [curr addUniqueObject:channel forKey:@"channels"];
                        [curr saveInBackground];
                    }
                }
            }
            [nc postNotificationName:LoadedRoundsWithCurrentUserAsArtist object:nil];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        NSLog(@"updated channels %@", [[PFInstallation currentInstallation] channels]);
    }];
}

- (GameRound *) makeNewRoundWithPlayer:(NSString *)player1 otherPlayer: (NSString *)player2 playerName: (NSString *) name1 otherName: (NSString *)name2 subjectBeingDrawn:(NSString *) friend {
    GameRound *gr;
    if ([self.playerRounds containsObject:player2]) {
        gr = [self findRoundWithCurrentPlayer:player1 otherPlayer:player2];
    } else if ((gr = [self checkIfRoundExistsAndSetAsCurrent:player2])) {
        gr.loadedRound = YES;
    } else {
        gr = [[GameRound alloc] initWithPlayer:player1 otherPlayer:player2 playerName:name1 otherName:name2 currentPlayerIsArtist:YES subjectBeingDrawn:friend order:self.gameRounds.count];
        
        [self.gameRounds addObject:gr];
        [self.playerRounds addObject:player2];
    }
    
    self.currentRound = gr;
    return gr;
}

- (GameRound *) makeNewRoundWithPlayer:(NSString *)player1 otherPlayer: (NSString *)player2 playerName: (NSString *) name1 otherName: (NSString *)name2 {
    GameRound *gr;
    NSLog(@"playerrounds %@ p2 %@", self.playerRounds, player2);
    if ([self.playerRounds containsObject:player2]) {
        NSLog(@"IN HERE 1 %@ %@", player1, player2);
        gr = [self findRoundWithCurrentPlayer:player1 otherPlayer:player2];
        gr.loadedRound = YES;
    } else if ((gr = [self checkIfRoundExistsAndSetAsCurrent:player2])) {
        NSLog(@"IN HERE 2 %@ %@", player1, player2);
        gr.loadedRound = YES;
    } else {
        NSLog(@"IN HERE %@ %@", player1, player2);
        gr = [[GameRound alloc] initWithPlayer:player1 otherPlayer:player2 playerName:name1 otherName:name2 currentPlayerIsArtist:YES order:self.gameRounds.count];
        [self.gameRounds addObject:gr];
        [self.playerRounds addObject:player2];
    }
    NSLog(@"gr %@ %@", gr.currentPlayer, gr.otherPlayer);
    self.currentRound = gr;
    return gr;
}

- (GameRound *)findRoundWithCurrentPlayer: (NSString *) player1 otherPlayer: (NSString *) player2 {
    int index = [self.playerRounds indexOfObject:player2];
    
    if (index != NSNotFound) {
        NSLog(@"returning existing OBJECT"); 
        return self.gameRounds[index];
    } else {
        return nil;
    }
}

- (GameRound *)checkIfRoundExistsAndSetAsCurrent:(NSString *) otherPlayer {
    GameRound *gr;
    PFQuery *queryGuesser = [PFQuery queryWithClassName:@"Round"];
    [queryGuesser whereKey:@"guesser" equalTo:[PFUser currentUser][@"DMFFacebookID"]];
    [queryGuesser whereKey:@"artist" equalTo:otherPlayer];
    PFObject *obj = [queryGuesser getFirstObject];
    if (obj) {
        gr = [[GameRound alloc] initWithRound:obj currentPlayerIsArtist:NO order:self.gameRounds.count];
        [self.gameRounds addObject:gr];
        [self.playerRounds addObject:obj[@"artist"]];
    }
    return gr;
}


@end
