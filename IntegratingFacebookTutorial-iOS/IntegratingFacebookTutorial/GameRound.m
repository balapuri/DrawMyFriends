//
//  GameRound.m
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/18/14.
//
//

#import "GameRound.h"
@interface GameRound ()

@end

@implementation GameRound

-(instancetype)initWithPlayer:(NSString *)player1 otherPlayer:(NSString *)player2 playerName: (NSString *) name1 otherName: (NSString *)name2 currentPlayerIsArtist: (BOOL) isArtist order:(int)num {
    if (self = [super init]) {
        _currentPlayer = player1;
        _otherPlayer = player2;
        _currentRound = [PFObject objectWithClassName:@"Round"];
        _roundOrder = num;
        _currentRound[@"player1Name"] = name1;
        _currentRound[@"player2Name"] = name2;
        _currentPlayerName = name1;
        _otherPlayerName = name2;
        
        if (isArtist) {
            _artist = _currentPlayer;
            _guesser = _otherPlayer;
            _currentRound[@"artist"] = player1;
            _currentRound[@"guesser"] = player2;
        } else {
            _artist = _otherPlayer;
            _guesser = _currentPlayer;
            _currentRound[@"artist"] = player2;
            _currentRound[@"guesser"] = player1;
        }
        [_currentRound saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.loadedRound=YES;
            }
        }];
    }
    return self;
}

- (instancetype) initWithPlayer: (NSString *)player1 otherPlayer:(NSString *)player2 playerName: (NSString *) name1 otherName: (NSString *)name2 currentPlayerIsArtist: (BOOL) isArtist subjectBeingDrawn:(NSString *)friend order: (int)num {
    if (self = [super init]) {
        _currentPlayer = player1;
        _otherPlayer = player2;
        _subjectBeingDrawn = friend;
        _currentRound = [PFObject objectWithClassName:@"Round"];
        _roundOrder = num;
        _currentRound[@"player1Name"] = name1;
        _currentRound[@"player2Name"] = name2;
        _currentPlayerName = name1;
        _otherPlayerName = name2;
        
        if (isArtist) {
            _artist = _currentPlayer;
            _guesser = _otherPlayer;
            _currentRound[@"artist"] = player1;
            _currentRound[@"guesser"] = player2;
        } else {
            _artist = _otherPlayer;
            _guesser = _currentPlayer;
            _currentRound[@"artist"] = player2;
            _currentRound[@"guesser"] = player1;
        }
        [_currentRound saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.loadedRound=YES;
            }
        }];
    }
    return self;
}

- (instancetype) initWithRound:(PFObject *)existingRound currentPlayerIsArtist: (BOOL) isArtist order: (int)num{
    self.loadedRound = YES;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (self = [super init]) {
        _subjectBeingDrawn = existingRound[@"subject"];
        _currentRound = existingRound;
        _roundOrder = num;
        
        PFFile *theImage = existingRound[@"imageFile"];
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            _drawing = [UIImage imageWithData:data];
            [nc postNotificationName:LoadedCurrentDrawing object:nil];
        }];

        
        if (existingRound[@"previousImageFile"]) {
            PFFile *thePreviousImage = existingRound[@"previousImageFile"];
            [thePreviousImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                _previousDrawing = [UIImage imageWithData:data];
                [nc postNotificationName:LoadedPreviousDrawing object:nil];
            }];
        }
        
        if (isArtist) {
            _currentPlayer = existingRound[@"artist"];
            _otherPlayer = existingRound[@"guesser"];
            _artist = _currentPlayer;
            _guesser = _otherPlayer;
            
        } else {
            _otherPlayer = existingRound[@"artist"];
            _currentPlayer = existingRound[@"guesser"];
            _artist = _otherPlayer;
            _guesser = _currentPlayer;
        }
        
        if ([[PFUser currentUser][@"name"] isEqualToString:existingRound[@"player1Name"]]) {
            _currentPlayerName = existingRound[@"player1Name"];
            _otherPlayerName = existingRound[@"player2Name"];
        } else {
            _currentPlayerName = existingRound[@"player2Name"];
            _otherPlayerName = existingRound[@"player1Name"];
        }
    }
    return self;
}

- (void)makeCurrentPlayerArtist {
    PFObject *obj = self.currentRound;
    obj[@"artist"] = self.currentPlayer;
    obj[@"guesser"] = self.otherPlayer;
    self.artist = self.currentPlayer;
    self.guesser = self.otherPlayer;
    [obj saveInBackground];
}

- (void)makeOtherPlayerArtist {
    PFObject *obj = self.currentRound;
    obj[@"artist"] = self.otherPlayer;
    obj[@"guesser"] = self.currentPlayer;
    self.artist = self.otherPlayer;
    self.guesser = self.currentPlayer;
    [obj saveInBackground];
    //obj[@"guess"] = @"";
}

- (void)clearGuess {
    PFObject *obj = self.currentRound;
    obj[@"guess"] = @"";
    [obj saveInBackground];
}
- (void) makeCurrentPlayerArtistAndClearGuess {
    PFObject *obj = self.currentRound;
    obj[@"artist"] = self.currentPlayer;
    obj[@"guesser"] = self.otherPlayer;
    self.artist = self.currentPlayer;
    self.guesser = self.otherPlayer;
    obj[@"guess"] = @"";
    
    [obj saveInBackground];
}
- (void)refreshValues {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [self.currentRound refresh];
    self.artist = self.currentRound[@"artist"];
    self.guesser = self.currentRound[@"guesser"];
    self.subjectBeingDrawn = self.currentRound[@"subject"];

    __weak GameRound *weakgr = self;

    PFFile *theImage = self.currentRound[@"imageFile"];
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        weakgr.drawing = [UIImage imageWithData:data];
        [nc postNotificationName:LoadedCurrentDrawing object:nil];
    }];

    PFFile *thePreviousImage = self.currentRound[@"previousImageFile"];
    [thePreviousImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        weakgr.previousDrawing = [UIImage imageWithData:data];
        [nc postNotificationName:LoadedPreviousDrawing object:nil];
    }];
}

- (void)storePreviousValues {
    PFObject *obj = self.currentRound;
    obj[@"previousGuess"] = obj[@"guess"];
    obj[@"previousGuesser"] = [PFUser currentUser][@"firstName"];
    obj[@"previousSubject"] = obj[@"subject"];
    obj[@"previousImageFile"] = obj[@"imageFile"];
    obj[@"sentBy"] = obj[@"artist"];
    [obj saveInBackground];
}

@end
