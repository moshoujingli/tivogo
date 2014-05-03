//
//  TVGBoardView.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-3.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//
#define PIECE_RADIO 17
#define OUT_BOARD_WIDTH 4
#define INSIDE_BOARD_WIDTH 2
#define BASE_OUT_SPEC 10
#define PIECE_OUTSIDE_SPEC (BASE_OUT_SPEC+INSIDE_BOARD_WIDTH+OUT_BOARD_WIDTH+1)
#import <UIKit/UIKit.h>
#import "gnugo.h"

@protocol RemoveDelegate <NSObject>
@required
-(void)eatOccur;

@end


@interface TVGBoardView : UIView
@property   (nonatomic)CGFloat spec;
@property (nonatomic)id<RemoveDelegate> removeDelegate;
-(BOOL)setPiece:(int)color at:(int)x and:(int)y;
-(void)indicate:(int)color at:(int)x and:(int)y;
-(BOOL)undo:(int)step;
-(void)sync;
-(void)showStepHint;
-(void)closeStepHint;
-(void)cleanStepHint;
//-(void)addMark:(NSString *)mark at:(int)pos;
//-(void)clearMark;
@end

