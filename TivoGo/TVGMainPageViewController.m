//
//  TVGViewController.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-11-21.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGMainPageViewController.h"
#import "UIImage+Tint.h"
@interface TVGMainPageViewController ()

@end

@implementation TVGMainPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIImage *image = self.infoBtn.image;
    self.infoBtn.image = [image imageWithTintColor:[UIColor colorWithRed:75/255.0 green:75/255.0 blue:75/255.0 alpha:1.0]];
    self.infoBtn.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(infoPushed)];
    [self.infoBtn addGestureRecognizer:tapBack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)infoPushed{
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"singlePlayer"]) {
        [segue.destinationViewController setValue:@"YES" forKey:@"isSingle"];
    }
}
@end
