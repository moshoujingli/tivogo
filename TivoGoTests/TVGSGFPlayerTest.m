//
//  TVGSGFPlayerTest.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-23.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TVGSGFTree.h"
@interface TVGSGFPlayerTest : XCTestCase

@end

@implementation TVGSGFPlayerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testInitAndFinalize
{
    TVGSGFTree *player = [[TVGSGFTree alloc]init];
    NSString *bundlePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"sgf"];
    if (bundlePath==nil) {
        XCTFail(@"bundle path cannot find");
    }
    NSString *sgfFileList = [bundlePath stringByAppendingPathComponent:@"26.sgf"];
    NSLog(@"%@",sgfFileList);
   player = [player initWithFile:sgfFileList];
    XCTAssertNotNil(player, @"cant init");
    NSMutableDictionary* info = player.gameInfo;
    NSEnumerator* keys = [info keyEnumerator];
    NSString * key;
    while (key = [keys nextObject]) {
        NSString *content = [info objectForKey:key];
        NSLog(@"%@ :%@",key,content);
    }
    MoveInfo move = [player getFirstMove];
    NSLog(@"%d play at (%d,%d)",move.color,move.x,move.y);
    while ((move=[player pullNextMove]).color) {
        NSLog(@"%d play at (%d,%d)",move.color,move.x,move.y);
        if (move.comment) {
            NSLog(@"comment is %@",[NSString stringWithUTF8String:move.comment]);
        }
    }
    int stat = [player close];
    XCTAssertEqual(stat,0,@"close failed");
}

@end
