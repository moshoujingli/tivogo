//
//  TVGWatchSGFViewController.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-3.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVGBoardView.h"
@interface TVGWatchSGFViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *sgfTitle;
@property (weak, nonatomic) IBOutlet UILabel *sgfDetail;
@property (weak, nonatomic) IBOutlet TVGBoardView *board;
@property (weak, nonatomic) IBOutlet UITableView *sgfFileList;
@property (weak, nonatomic) IBOutlet UISearchBar *sgfSearchBar;

@end
