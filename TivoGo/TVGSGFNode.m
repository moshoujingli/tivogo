//
//  TVGSGFNode.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-30.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGSGFNode.h"

@implementation TVGSGFNode
-(NSArray *)getPropertyByName:(NSString *) name{
    return nil;
}
-(void)printPropertys{
    for (TVGSGFProperty *prop in self.props) {
        NSLog(@"%d %@",prop.rawName,[[NSString alloc]initWithUTF8String:prop.rawValue]);
    }
}



@end
