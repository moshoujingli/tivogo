//
//  TVGSettingViewController.h
//  TivoGo
//
//  Created by BiXiaopeng on 14-1-4.
//  Copyright (c) 2014年 BiXiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVGSettingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *rule;
@property (weak, nonatomic) IBOutlet UISwitch *komi;
@property (weak, nonatomic) IBOutlet UISwitch *countTime;
@property (weak, nonatomic) IBOutlet UISwitch *bgm;
@property (weak, nonatomic) IBOutlet UISwitch *sound;
@property (weak, nonatomic) IBOutlet UIImageView *backBtn;
@property (weak, nonatomic) IBOutlet UISwitch *useBlack;

@end
