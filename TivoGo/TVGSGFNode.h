//
//  TVGSGFNode.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-30.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TVGSGFProperty.h"
@interface TVGSGFNode : NSObject
@property (nonatomic,readonly)BOOL isMoveNode;
@property (nonatomic)BOOL isLeaf;
@property (nonatomic)NSUInteger nodeID;
@property   (nonatomic)NSUInteger parentID;
@property   (nonatomic)NSUInteger nextStepID;
@property   (nonatomic)NSMutableArray* otherVaris;
@property (nonatomic)NSArray *props;
-(NSArray *)getPropertyByName:(NSString *) name;
-(void)printPropertys;
@end
