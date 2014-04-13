//
//  TVGSGFNode.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-30.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGSGFNode.h"

@implementation TVGSGFNode
@synthesize otherVaris=_otherVaris;
@synthesize isMoveNode=_isMoveNode;
-(BOOL)isMoveNode{
    _isMoveNode = [self getPropertyByName:@"move"].count!=0;
    return _isMoveNode;
}
-(NSArray *)otherVaris{
    if (!_otherVaris) {
        _otherVaris= [[NSMutableArray alloc]init];
    }
    return _otherVaris;
}
-(NSArray *)getPropertyByName:(NSString *) name{
    NSMutableArray *rtnArr = [[NSMutableArray alloc]init];
    for (TVGSGFProperty *pro in self.props) {
        if ([pro.propName isEqualToString:name]) {
            [rtnArr addObject:pro];
        }
    }
    return rtnArr;
}
-(void)printPropertys{
    for (TVGSGFProperty *prop in self.props) {
        NSLog(@"%d %@",prop.rawName,[[NSString alloc]initWithUTF8String:prop.rawValue]);
    }
}



@end
