//
//  TVGSinglePlayerController.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-11.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <gnugo.h>
#import "TVGBoardView.h"
@interface TVGPlayerController : UIViewController
@property (weak, nonatomic) IBOutlet TVGBoardView *board;
@property (weak, nonatomic) IBOutlet UILabel *opponentLabel;
@property  (nonatomic)NSString* isSingle;
@end
