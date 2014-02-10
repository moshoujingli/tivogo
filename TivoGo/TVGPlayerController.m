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
@property  (nonatomic)Gameinfo gameInfo;
@property (nonatomic)dispatch_queue_t computeQueue;
@property (nonatomic)BOOL isThingking;
@end

@implementation TVGPlayerController
@synthesize whoPlayThisMove=_whoPlayThisMove;
@synthesize isSingle=_isSingle;
@synthesize gameInfo=_gameInfo;
@synthesize computeQueue=_computeQueue;
@synthesize isThingking=_isThingking;
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
        _whoPlayThisMove=OTHER_COLOR(_whoPlayThisMove);
        if (self.isSingle) {
            self.opponentLabel.text=@"Thingking...";
            self.isThingking=YES;
            
//            [NSThread detachNewThreadSelector:@selector(getMove) toTarget:self withObject:nil];
//            NSThread *thinkThread = [[NSThread alloc]initWithTarget:self selector:@selector(getMove) object:nil];
//            [thinkThread setStackSize:(1024*1024*10)];
//            [thinkThread start];
            __weak TVGPlayerController *weakSelf = self;
            int computermove = self.whoPlayThisMove;
            dispatch_async(self.computeQueue, ^(){
                int move = genmove(computermove, NULL, NULL);
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [weakSelf.board setPiece:weakSelf.whoPlayThisMove at:I(move) and:J(move)];
                    _whoPlayThisMove=OTHER_COLOR(_whoPlayThisMove);
                    [weakSelf.board setNeedsDisplay];
                    weakSelf.isThingking=NO;
                    weakSelf.opponentLabel.text=@"GNUGO ROBOT";
                });
            });
            
        }
    }
}

-(void)refresh:(NSNumber *)move{
    [self.board setPiece:self.whoPlayThisMove at:I(move.intValue) and:J(move.intValue)];
    _whoPlayThisMove=OTHER_COLOR(_whoPlayThisMove);
    [self.board setNeedsDisplay];
    self.isThingking=NO;
    self.opponentLabel.text=@"GNUGO ROBOT";

}

-(void)getMove{
    int move = genmove(self.whoPlayThisMove, NULL, NULL);
    [self performSelectorOnMainThread:@selector(refresh:) withObject:[[NSNumber alloc]initWithInt:move] waitUntilDone:YES];
}

-(void)makeIndicateTo:(CGPoint)pos withColor:(int)color{
    pos=[self translateLocToIndex:pos];
    [self.board indicate:color at:pos.x and:pos.y];
}


- (IBAction)tap:(UITapGestureRecognizer *)sender {
    if (self.isThingking) {
        return;
    }
    if (sender.state==UIGestureRecognizerStateEnded) {
        [self makeMoveTo:[sender locationInView:self.board] withColor:self.whoPlayThisMove];
    }
}
- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    if (self.isThingking) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint pos = [sender locationInView:self.board];
        [self    makeIndicateTo:pos withColor:self.whoPlayThisMove];
    }else if(sender.state == UIGestureRecognizerStateEnded){
        [self makeMoveTo:[sender locationInView:self.board] withColor:self.whoPlayThisMove];
    }
}
- (IBAction)retractPushed:(UIButton *)sender {
    if (self.isSingle) {
        [self.board undo:2];
    }else{
        [self.board undo:1];
        _whoPlayThisMove=OTHER_COLOR(_whoPlayThisMove);
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
    if (self.isSingle) {
        NSLog(@"single player");
        self.computeQueue = dispatch_queue_create("computeQueue", NULL);
        self.opponentLabel.text = @"GNUGO ROBOT";
    }
}
-(void)initGame{
    _whoPlayThisMove=BLACK;
    gameinfo_clear(&(_gameInfo));
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backPushed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
