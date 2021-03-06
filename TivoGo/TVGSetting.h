//
//  TVGSetting.h
//  TivoGo
//
//  Created by BiXiaopeng on 14-1-24.
//  Copyright (c) 2014年 BiXiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface TVGSetting : NSObject
@property (nonatomic)BOOL isChineseRule;
@property (nonatomic)BOOL useCountTime;
@property (nonatomic)BOOL useKomi;
@property (nonatomic)BOOL useBGM;
@property (nonatomic)BOOL useSound;
@property (nonatomic)BOOL firstOpen;
@property (nonatomic)BOOL useBlack;
@property (nonatomic)NSString* sum;
-(void)flush;
+(TVGSetting *)getInstnce;
@end
