//
//  TVGMoveGenerater.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-23.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVGMoveListener.h"
@protocol TVGMoveGenerater <NSObject>
-(int)registeMoveListener:(id<TVGMoveListener>)listener;
@end
