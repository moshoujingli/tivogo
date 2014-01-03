//
//  TVGGnugoAPITest.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-31.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "gnugo.h"
@interface TVGGnugoAPITest : XCTestCase

@end

@implementation TVGGnugoAPITest



- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testPlayWithComputer
{
    init_gnugo(32, 10);
    gnugo_clear_board(19);
    gnugo_play_move(POS(3, 3), BLACK);
    int move = genmove(WHITE, NULL, NULL);
    NSLog(@"%d,%d",I(move),J(move));
    gnugo_play_move(move, WHITE);
    gnugo_play_move(POS(16,16), BLACK);
    move = genmove(WHITE, NULL, NULL);
    NSLog(@"%d,%d",I(move),J(move));
    gnugo_play_move(move, WHITE);
    gnugo_play_move(POS(3,16), BLACK);
    move = genmove(WHITE, NULL, NULL);
    NSLog(@"%d,%d",I(move),J(move));
    gnugo_play_move(move, WHITE);
    gnugo_play_move(genmove(WHITE, NULL, NULL), WHITE);
    gnugo_play_move(POS(3,14), BLACK);
    gnugo_play_move(genmove(WHITE, NULL, NULL), WHITE);
    gnugo_play_move(POS(1,14), BLACK);
    gnugo_play_move(genmove(WHITE, NULL, NULL), WHITE);
    gnugo_play_move(POS(7,14), BLACK);
    gnugo_play_move(genmove(WHITE, NULL, NULL), WHITE);
    for (int i=0;i<19 ; i++) {
        NSLog(@"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",BOARD(i,0),BOARD(i,1),BOARD(i,2),BOARD(i,3),BOARD(i,4),BOARD(i,5),BOARD(i,6),BOARD(i,7)
              ,BOARD(i,8),BOARD(i,9),BOARD(i,10),BOARD(i,11),BOARD(i,12),BOARD(i,13),BOARD(i,14),BOARD(i,15),BOARD(i,16),BOARD(i,17),BOARD(i,18)
              );
    }
    NSLog(@"%f",gnugo_estimate_score(NULL, NULL));
    
    undo_move(2);
    
    for (int i=0;i<19 ; i++) {
        NSLog(@"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",BOARD(i,0),BOARD(i,1),BOARD(i,2),BOARD(i,3),BOARD(i,4),BOARD(i,5),BOARD(i,6),BOARD(i,7)
              ,BOARD(i,8),BOARD(i,9),BOARD(i,10),BOARD(i,11),BOARD(i,12),BOARD(i,13),BOARD(i,14),BOARD(i,15),BOARD(i,16),BOARD(i,17),BOARD(i,18)
              );
    }
    NSLog(@"%f",gnugo_estimate_score(NULL, NULL));

}
- (void)testPlayWithPlayer
{
    gnugo_clear_board(19);
    gnugo_play_move(POS(3, 3), BLACK);
    gnugo_play_move(POS(3, 4), WHITE);
    gnugo_play_move(POS(16,16), BLACK);
    gnugo_play_move(POS(16, 17), WHITE);
    gnugo_play_move(POS(3,16), BLACK);
    gnugo_play_move(POS(3,17), WHITE);
    gnugo_play_move(POS(2,15), BLACK);
    gnugo_play_move(genmove(WHITE, NULL, NULL), WHITE);
    gnugo_play_move(POS(3,14), BLACK);
    gnugo_play_move(genmove(WHITE, NULL, NULL), WHITE);
    gnugo_play_move(POS(1,14), BLACK);
    gnugo_play_move(genmove(WHITE, NULL, NULL), WHITE);
    gnugo_play_move(POS(1,1), WHITE);
    for (int i=0;i<19 ; i++) {
        NSLog(@"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",BOARD(i,0),BOARD(i,1),BOARD(i,2),BOARD(i,3),BOARD(i,4),BOARD(i,5),BOARD(i,6),BOARD(i,7)
              ,BOARD(i,8),BOARD(i,9),BOARD(i,10),BOARD(i,11),BOARD(i,12),BOARD(i,13),BOARD(i,14),BOARD(i,15),BOARD(i,16),BOARD(i,17),BOARD(i,18)
              );
    }
    NSLog(@"%f",gnugo_estimate_score(NULL, NULL));
}


@end
