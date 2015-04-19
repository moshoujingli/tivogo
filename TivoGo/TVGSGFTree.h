//
//  TVGSGFPlayer.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-23.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVGSGFNode.h"
#import "TVGSGFProperty.h"

@interface TVGSGFTree : NSObject
@property (nonatomic,readonly)NSMutableDictionary *gameInfo;
-(TVGSGFNode *)getNodeById:(NSUInteger) nodeId;
-(TVGSGFNode *)getRootNode;
-(TVGSGFTree *)initWithFile:(NSString *)filePath;
-(int)close;
@end
