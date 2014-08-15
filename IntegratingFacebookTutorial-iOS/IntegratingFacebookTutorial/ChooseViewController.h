//
//  ChooseViewController.h
//  StoryTeller
//
//  Created by Maya Reddy on 7/16/14.
//
//

#import <UIKit/UIKit.h>

@interface ChooseViewController : UIViewController <NSURLConnectionDataDelegate, UITableViewDelegate,UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *friendTableView;

@property (nonatomic) int whichPic;
@property (nonatomic, strong) NSMutableData *imageData;

@end
