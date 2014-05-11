//
//  TVGWatchSGFViewController.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-3.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVGBoardView.h"
#import "TVGSGFTree.h"
@interface TVGWatchSGFViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *sgfTitle;
@property (weak, nonatomic) IBOutlet TVGBoardView *board;
@property (weak, nonatomic) IBOutlet UITableView *sgfFileList;
@property (weak, nonatomic) IBOutlet UISearchBar *sgfSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *sgfTable;
@property (weak, nonatomic) IBOutlet UITextView *sgfDetail;
@property (weak, nonatomic) IBOutlet UIImageView *backBtn;
@property (weak, nonatomic) IBOutlet UIImageView *nextBtn;
@property (weak, nonatomic) IBOutlet UIImageView *toStart;
@property (weak, nonatomic) IBOutlet UIImageView *nextTenPass;
@property (weak, nonatomic) IBOutlet UIImageView *prevTenPass;
@property (weak, nonatomic) IBOutlet UILabel *player;
@property (weak, nonatomic) IBOutlet UITextView *sgfComment;
@property (weak, nonatomic) IBOutlet UIButton *changeStepHintBtn;


@end
