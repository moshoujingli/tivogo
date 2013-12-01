//
//  TVGSGFTreeText.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-30.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TVGSGFTree.h"
@interface TVGSGFTreeTest : XCTestCase
@property (nonatomic)TVGSGFTree *testTree;
@property (nonatomic)NSString *testFileName;
@end

@implementation TVGSGFTreeTest
@synthesize testFileName=_testFileName;
@synthesize testTree=_testTree;

-(NSString *)testFileName{
    if (!_testFileName) {
        NSString *bundlePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"sgf"];
        if (bundlePath==nil) {
            XCTFail(@"bundle path cannot find");
        }
        _testFileName = [bundlePath stringByAppendingPathComponent:@"test.sgf"];
    }
    return _testFileName;
}
- (void)setUp
{
    [super setUp];
    self.testTree=[[TVGSGFTree alloc]initWithFile:self.testFileName];
    NSMutableDictionary *info = self.testTree.gameInfo;
    NSEnumerator* keys = [info keyEnumerator];
    NSString * key;
    while (key = [keys nextObject]) {
        NSString *content = [info objectForKey:key];
        NSLog(@"%@ :%@",key,content);
    }

}

- (void)tearDown
{
    [self.testTree close];
    [super tearDown];
}

- (void)testGetRoot
{
    TVGSGFNode *node = [self.testTree getRootNode];
    XCTAssertNotNil(node, @"cant get root node.");
    [self printGoChain:node];
    
}
-(void)printGoChain:(TVGSGFNode *)node{
    [node printPropertys];
    for (int nodeID=node.nextStepID; !node.isLeaf; nodeID=node.nextStepID) {
        node=[self.testTree getNodeById:nodeID];
        [node printPropertys];

        if (node.otherVaris) {
            for (NSNumber *varNodeID in node.otherVaris) {
                NSLog(@"----print varis");
                [self printGoChain:[self.testTree getNodeById:[varNodeID intValue] ]];
                NSLog(@"----print varis end");
            }
        }
    }
}

@end
