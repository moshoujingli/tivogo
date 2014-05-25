//
//  TVGSinglePlayerController.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-11.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <gnugo.h>
#import "TVGBoardView.h"
#import "UIView+Toast.h"
#import <AVFoundation/AVFoundation.h>
@interface TVGPlayerController : UIViewController<AVAudioPlayerDelegate,RemoveDelegate, UIAlertViewDelegate >
@property (weak, nonatomic) IBOutlet TVGBoardView *board;
@property (weak, nonatomic) IBOutlet UILabel *whiteCounterLabel;
@property (weak, nonatomic) IBOutlet UILabel *blackCounterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *whiteHint;
@property (weak, nonatomic) IBOutlet UIImageView *blackHint;
@property (weak, nonatomic) IBOutlet UIButton *countBtn;
@property  (nonatomic)NSString* isSingle;
@end
