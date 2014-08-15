//
//  FriendSubjects.m
//  DrawMyFriends
//
//  Created by Maya Reddy on 7/17/14.
//
//

#import "FriendSubjects.h"
#import <Parse/Parse.h>
#import "RoundStore.h"
#import "GameRound.h"

@interface FriendSubjects ()


@end

@implementation FriendSubjects

+ (instancetype)sharedFriends {
    static FriendSubjects *sharedFriends;
    
    if (!sharedFriends) {
        sharedFriends = [[self alloc] initPrivate];
    }
    return sharedFriends;
}

- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[FriendSubjects sharedFriends]"];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        [self getFriends];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

+ (int)getNumFriends {
    return numFriends;
}

- (void) getFriends {
    GameRound *gr = [RoundStore sharedStore].currentRound;
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"me/mutualfriends/%@?fields=name,picture",gr.otherPlayer] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSMutableString *usedIndices = [[NSMutableString alloc] init];
        if (!error) {
            NSArray *data = result[@"data"];
            self.nameList = [[NSMutableArray alloc] init];
            self.urlList = [[NSMutableArray alloc] init];
            
            if (maxNumFriends > [data count]) {
                numFriends = [data count];
            } else {
                numFriends = maxNumFriends;
            }
            
            for (int i = 0; i < numFriends; i++) {
                int index = arc4random() % [data count];
                NSString *indexString = [NSString stringWithFormat:@"num %d", index];
                while ([usedIndices rangeOfString:indexString].length != 0) {
                    index = arc4random() % [data count];
                    indexString = [NSString stringWithFormat:@"num %d", index];
                }
                [usedIndices appendString:indexString];
                NSString *pictureString = ((NSDictionary *)data[index][@"picture"][@"data"])[@"url"];
                
                [_urlList addObject:pictureString];
                
                
                NSString *name = data[index][@"name"];
                [self.nameList addObject:name];
            }
            
            [self getProfilePictures];
            [[NSNotificationCenter defaultCenter] postNotificationName:LoadedMutualFriends object:nil];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            //[self logoutButtonTouchHandler:nil];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];

}

- (void)getProfilePictures {
    if (!self.imageList) {
        self.imageList = [[NSMutableArray alloc] init];
        for (int i = 0; i < numFriends; i++) {
            [self.imageList addObject:[NSNull null]];
        }
    } else {
        for (int i = 0; i < numFriends; i++) {
            self.imageList[i] = [NSNull null];
        }
    }
    self.imageOrderList = [[NSMutableArray alloc] init];
    for (int i = 0; i < numFriends; i++) {
        NSString *url = self.urlList[i];
        [self addPhotoWithURLString:url name:self.nameList[i]];
    }
}

- (NSArray *) getPhotos {
    return self.imageList;
}

- (NSArray *) getNames {
    return self.nameList;
}

- (NSArray *) getUrls {
    return self.urlList;
}

- (void) refreshFriends {
    [self getFriends];
}

- (void)addPhotoWithURLString:(NSString *)url name: (NSString *)name {
    if (!self.imageData) {
        self.imageData = [[NSMutableData alloc] init];
    }
    
    NSURL *pictureURL = [NSURL URLWithString:url];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval:2.0f];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    [self.imageOrderList addObject:[urlConnection originalRequest]];
    
    if (!urlConnection) {
        NSLog(@"Failed to download picture");
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chunks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    UIImage *img = [UIImage imageWithData:self.imageData];
    
    int index = [self.imageOrderList indexOfObject:[connection originalRequest]];
    
    if (index >= 0 && index < self.imageList.count && img) {
        self.imageList[index] = img;
        
        if (self.imageList.count == numFriends) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LoadedMutualFriendsPictures object:nil];
        }
    }
    self.imageData = [self.imageData init];
}

@end
