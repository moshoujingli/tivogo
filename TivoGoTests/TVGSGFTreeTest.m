//
//  TVGSGFTreeText.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-30.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TVGSGFTree.h"
#include "include/sgftree.h"
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
}
-(void)testPhaseArray{
    TVGSGFNode *node = [self.testTree getRootNode];
    NSUInteger prevID =0;
    NSUInteger zero=0;
    XCTAssertTrue(node.nodeID==zero, @"node id is %d",node.nodeID);
    XCTAssertTrue(node.otherVaris.count==zero,  @"root cant have othervars");
    node=[self.testTree getNodeById:node.nextStepID];
    for (; !node.isLeaf; node=[self.testTree getNodeById:node.nextStepID]) {
        XCTAssertEqual(prevID, node.parentID, @"prev id is %d ,now node parent id is %d,now node id is %d",prevID,node.parentID,node.nodeID);
        if (node.otherVaris) {
            for (NSNumber *ids in node.otherVaris) {
                TVGSGFNode *tmpBranchNode = [self.testTree getNodeById:[ids intValue] ];
                XCTAssertEqual(prevID,tmpBranchNode.parentID,@"prev id is %d ,now node parent id is %d,now node id is %d",prevID,tmpBranchNode.parentID,tmpBranchNode.nodeID);
            }
        }
        prevID=node.nodeID;
    }
    node =[self.testTree getNodeById:4];
    TVGSGFProperty* prop = [node.props objectAtIndex:1];
    XCTAssertTrue([prop.propName isEqualToString:@"comment"], @"is not comment,it is %@",prop.propName);
	XCTAssertTrue(node.otherVaris.count==1, @"the node 4,with comment %s",prop.rawValue);
    node = [self.testTree getNodeById:node.nextStepID];
    XCTAssertTrue(node.otherVaris.count==3, @"the node %d,with comment %s,has vars %d",node.nodeID,((TVGSGFProperty *)[node.props objectAtIndex:1]).rawValue,node.otherVaris.count);
    
}
-(void)testSimulatePlay{
    TVGSGFNode *node = [self.testTree getRootNode];
    if (node.nodeID==0) {
        NSArray * props =[node getPropertyByName:@"player_b"];
        XCTAssertTrue(props.count==1, @"only can have 1 player black the two is %s",((TVGSGFProperty *)[props objectAtIndex:1]).rawValue);
        NSString *blackPlayerName =((TVGSGFProperty *)[props objectAtIndex:0]).propValue;
        XCTAssertTrue([@"安田秀策" isEqualToString:blackPlayerName], @"bad player %@",blackPlayerName);
        
        props =[node getPropertyByName:@"player_w"];
        NSString *whitePlayerName =((TVGSGFProperty *)[props objectAtIndex:0]).propValue;
        XCTAssertTrue([@"幻庵因硕" isEqualToString:whitePlayerName], @"bad player %@",blackPlayerName);
    }
    node=[self.testTree getNodeById:node.nextStepID];
    int moveNodeCount=0;
    for (; !node.isLeaf; node=[self.testTree getNodeById:node.nextStepID]) {
        if (node.isMoveNode) {
            moveNodeCount++;
            //get move locate and color
            NSArray* move = [node getPropertyByName:@"move"];
            XCTAssertTrue(move.count==1, @"move node can only be one now is %d",move.count);
            TVGMove *mvPoint =  ((TVGSGFProperty *)[move objectAtIndex:0]).propValue;
            XCTAssertTrue(mvPoint.x>=0&&mvPoint.x<=19, @"point x out of range %d",mvPoint.x);
            XCTAssertTrue(mvPoint.y>=0&&mvPoint.y<=19, @"point y out of range %d",mvPoint.y);
            XCTAssertTrue(mvPoint.player==WHITE||mvPoint.player==BLACK, @"player dont know %d",mvPoint.player);
            NSLog(@"%s",((TVGSGFProperty *)[move objectAtIndex:0]).rawValue);
        }
    }
    XCTAssertEqual(moveNodeCount, 6, @"lost move node ,cur is %d",moveNodeCount);
}
@end
