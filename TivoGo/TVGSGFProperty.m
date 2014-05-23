//
//  TVGSGFProperty.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-30.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGSGFProperty.h"
#include "sgftree.h"
#define LABEL_TRIANGLE 33
#define CUR_ENCODING ([NSLocalizedString(@"LanguageCode", nil) isEqualToString:@"ja"]?NSShiftJISStringEncoding:NSUTF8StringEncoding)

@interface TVGSGFProperty ()
@end

@implementation TVGSGFProperty
@synthesize propName=_propName;
@synthesize propValue=_propValue;

-(TVGMove *)getMoveInfoofPlayer:(short)player{
    TVGMove * move = [[TVGMove alloc]init];
    move.player = player;
    SGFProperty pro;
    if (player==EMPTY) {
        move.label = [[NSString alloc]initWithUTF8String:(self.rawValue+3)];
    }else if(player==LABEL_TRIANGLE){
        move.label = @"△";
    }
    pro.value=self.rawValue;
    move.x=get_moveX(&pro, 19);
    move.y=get_moveY(&pro, 19);
    return move;
}
-(NSString *)propName{
    if (!_propName) {
        switch (self.rawName) {
            case SGFLB:
                _propName=@"label";
                _propValue=[self getMoveInfoofPlayer:EMPTY];
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
                _propValue=[[NSString alloc]initWithBytes:self.rawValue length:strlen(self.rawValue) encoding:CUR_ENCODING];
                break;
            case SGFPB:
                _propName=@"player_b";
                _propValue=[[NSString alloc]initWithBytes:self.rawValue length:strlen(self.rawValue) encoding:CUR_ENCODING];
                break;
            case SGFPW:
                _propName=@"player_w";
                _propValue=[[NSString alloc]initWithBytes:self.rawValue length:strlen(self.rawValue) encoding:CUR_ENCODING];
                break;
            case SGFTR:
                _propName=@"label";
                _propValue=[self getMoveInfoofPlayer:LABEL_TRIANGLE];
                break;
            default:
                _propName=@"unknow";
                break;
        }
        
    }
    return _propName;
}
@end
