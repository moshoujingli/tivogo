//
//  TVGSGFProperty.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-30.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct MoveInfo_t{
    short color;
    short x;
    short y;
    char* comment;
}MoveInfo;

@interface TVGSGFProperty : NSObject
@property (nonatomic)char * rawValue;
@property   (nonatomic)int rawName;
@property   (nonatomic)NSString *propName;
@property   (nonatomic,readonly)MoveInfo propMove;
@property   (nonatomic,readonly)NSString *propComment;

@end
