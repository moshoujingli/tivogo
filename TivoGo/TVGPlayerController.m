//
//  TVGSinglePlayerController.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-11.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGPlayerController.h"
@interface TVGPlayerController ()
@property (nonatomic,readonly) int whoPlayThisMove;
@end

@implementation TVGPlayerController
@synthesize whoPlayThisMove=_whoPlayThisMove;

-(CGPoint)translateLocToIndex:(CGPoint)pos{
    float spec = self.board.spec;
    pos.x=(int)((pos.x-PIECE_OUTSIDE_SPEC)/spec+0.5);
    pos.y=(int)((pos.y-PIECE_OUTSIDE_SPEC)/spec+0.5);
    return pos;
}

- (void)makeMoveTo:(CGPoint)pos withColor:(int)color {
    pos=[self translateLocToIndex:pos];
    BOOL do_play= [self.board setPiece:color at:pos.x and:pos.y];
    [self.board indicate:EMPTY at:0 and:0];
    if(do_play) {
        _whoPlayThisMove=BLACK+WHITE-(_whoPlayThisMove);
    }
}
-(void)makeIndicateTo:(CGPoint)pos withColor:(int)color{
    pos=[self translateLocToIndex:pos];
    [self.board indicate:color at:pos.x and:pos.y];
}


- (IBAction)tap:(UITapGestureRecognizer *)sender {
    if (sender.state==UIGestureRecognizerStateEnded) {
        [self makeMoveTo:[sender locationInView:self.board] withColor:self.whoPlayThisMove];
    }
}
- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint pos = [sender locationInView:self.board];
        [self    makeIndicateTo:pos withColor:self.whoPlayThisMove];
    }else if(sender.state == UIGestureRecognizerStateEnded){
        [self makeMoveTo:[sender locationInView:self.board] withColor:self.whoPlayThisMove];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initGame];
}
-(void)initGame{
    _whoPlayThisMove=BLACK;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
