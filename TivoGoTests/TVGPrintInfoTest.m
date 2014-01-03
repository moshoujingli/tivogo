//
//  TVGPrintInfoTest.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-23.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TVGSGFTree.h"

@interface TVGPrintInfoTest : XCTestCase
@property (nonatomic)TVGSGFTree *testTree;
@end

@implementation TVGPrintInfoTest

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

- (void)testExample
{
    for (int i=1; i<40; i++) {
        
        NSString *bundlePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"sgf"];
        if (bundlePath==nil) {
            XCTFail(@"bundle path cannot find");
        }
        NSString *fileName = [bundlePath stringByAppendingPathComponent:[ [NSString alloc]initWithFormat:@"%d.sgf",i]];
        self.testTree=[[TVGSGFTree alloc]initWithFile:fileName];
        NSMutableDictionary *info = self.testTree.gameInfo;
        NSEnumerator* keys = [info keyEnumerator];
        NSString * key;
        while (key = [keys nextObject]) {
            NSString *content = [info objectForKey:key];
            NSLog(@"%@ :%@",key,content);
        }

        
    }
}

@end
