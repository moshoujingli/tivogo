//
//  TVGSGFProperty.h
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-30.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVGMove.h"
@interface TVGSGFProperty : NSObject
@property (nonatomic)char * rawValue;
@property   (nonatomic)int rawName;
@property (nonatomic,readonly)id propValue;
@property   (nonatomic,readonly)NSString *propName;
@end
