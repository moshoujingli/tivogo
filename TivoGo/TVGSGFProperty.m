//
//  TVGSGFProperty.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-30.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGSGFProperty.h"
#include "sgftree.h"
@implementation TVGSGFProperty
@synthesize propName=_propName;
@synthesize propValue=_propValue;
-(TVGMove *)getMoveInfoofPlayer:(short)player{
    TVGMove * move = [[TVGMove alloc]init];
    move.player = player;
    SGFProperty pro;
    pro.value=self.rawValue;
    move.x=get_moveX(&pro, 19);
    move.y=get_moveY(&pro, 19);
    return move;
}
-(NSString *)propName{
    if (!_propName) {
        switch (self.rawName) {
            case SGFLB:
                _propName=@"lable";
                break;
            case SGFB:
                _propName=@"move";
                _propValue=[self getMoveInfoofPlayer:BLACK];
                break;
            case SGFW:
                _propName=@"move";
                _propValue=[self getMoveInfoofPlayer:WHITE];
                break;
            case SGFC:
                _propName=@"comment";
                _propValue=[[NSString alloc]initWithUTF8String:self.rawValue];
                break;
            case SGFPB:
                _propName=@"player_b";
                _propValue=[[NSString alloc]initWithUTF8String:self.rawValue];
                break;
            case SGFPW:
                _propName=@"player_w";
                _propValue=[[NSString alloc]initWithUTF8String:self.rawValue];
                break;
            default:
                _propName=@"unknow";
                break;
        }
        
    }
    return _propName;
}
@end
