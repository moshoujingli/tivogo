//
//  TVGBoardView.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-3.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//


#import "TVGBoardView.h"
@interface TVGBoardView()
@property   (nonatomic)CGFloat lineEnd;
@property   (nonatomic)int indicateColor;
@property   (nonatomic)CGPoint indicatePos;
@property (nonatomic)CGFloat outside;
@property Intersection *boardToShow;
@property int *boardShowStepHint;
@property int curStepCount;
@property (nonatomic)UIImage *blackPiece;
@property (nonatomic)UIImage *whitePiece;
@property (nonatomic)UIImage *board;
@property (nonatomic)int lastPlayPointPos;
@property (nonatomic)int lastPlayPointColor;
@property (nonatomic)BOOL needShowStepHint;
@property (nonatomic)NSMutableArray* labelMoveArray;
@end

@implementation TVGBoardView
@synthesize curStepCount=_curStepCount;
@synthesize lineEnd=_lineEnd;
@synthesize spec=_spec;
@synthesize outside=_outside;
@synthesize indicateColor=_indicateColor;
@synthesize indicatePos=_indicatePos;

-(void)awakeFromNib{
    [super awakeFromNib];
    gnugo_clear_board(19);
    self.lineEnd = self.frame.size.width-PIECE_OUTSIDE_SPEC;
    self.spec = self.frame.size.width*0.05193;
    self.outside = self.frame.size.width*0.0332;
    self.boardShowStepHint = (int *)calloc(BOARDSIZE, sizeof(int));
    self.boardToShow = (Intersection *)calloc(BOARDSIZE,sizeof(Intersection));
    self.board = [UIImage imageNamed:@"Board_pad.png"];
    self.blackPiece = [UIImage imageNamed:@"black_piece.png"];
    self.whitePiece = [UIImage imageNamed:@"white_piece.png"];
    self.lastPlayPointPos = -1;
    self.curStepCount=0;
    self.needShowStepHint=NO;
    self.labelMoveArray = [[NSMutableArray alloc]init];
}

-(BOOL)setPiece:(int)color at:(int)x and: (int)y{
    //NSLog(@"%d,%d this is %d",x,y,BOARD(x, y));
    if (color==PASS_MOVE) {
        return YES;
    }
    if (IS_STONE(BOARD(x, y))) {
        NSLog(@"not empty");
        return NO;
    }
    gnugo_play_move(POS(x, y), color);
    self.boardToShow[POS(x, y)]=color;
    self.curStepCount++;
    self.boardShowStepHint[POS(x, y)]=self.curStepCount;
    int cpr = memcmp(board, self.boardToShow,sizeof(board));
    if (cpr) {
        memcpy(self.boardToShow, board, sizeof(board));
        if (cpr<0&&self.removeDelegate) {
            [self.removeDelegate eatOccur];
        }
    }
    self.lastPlayPointPos = POS(x, y);
    self.lastPlayPointColor = color;
    [self setNeedsDisplay];
    return YES;
}

-(void)indicate:(int)color at:(int)x and:(int)y{
    CGFloat lspec = self.spec;
    self.indicatePos=CGPointMake(self.outside+lspec*x, self.outside+lspec*y);
    self.indicateColor=color;
    if (color!=EMPTY) {
        [self setNeedsDisplay];
    }
}

-(BOOL)undo:(int)step{
    int success = undo_move(step);
    if (success) {
        self.lastPlayPointPos=-1;
        self.curStepCount-=step;
        for (int i=0; i<BOARDSIZE; i++) {
            if (self.boardShowStepHint[i]>self.curStepCount) {
                self.boardShowStepHint[i]=0;
            }
        }
        memcpy(self.boardToShow, board, sizeof(board));
        [self setNeedsDisplay];
        return YES;
    }
    return NO;

}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBoard:context];
    [self drawPieces:context];
    if (self.indicateColor) {
        [self drawPiece:context withColor:self.indicateColor at:self.indicatePos];
    }
    if (self.needShowStepHint) {
        [self drawStepHint:context];
    }else{
        if (self.lastPlayPointPos>=0) {
            [self drawLastPlayIndicate:context at:self.lastPlayPointPos];
        }
    }
    if ([self.labelMoveArray count]>0) {
        [self drawLabel:context];
    }
}
-(void)drawLabel:(CGContextRef)context {
    UIGraphicsPushContext(context);
    CGFloat lspec = self.spec;
    
    for (TVGSGFProperty* moveProp in self.labelMoveArray) {
        TVGMove* labelMove =  moveProp.propValue;
        [self drawLabelHint:context withStepCount:labelMove.label at:CGPointMake(self.outside+lspec*labelMove.x, self.outside+lspec*labelMove.y) ];
    }
    UIGraphicsPopContext();
}
-(void)drawLastPlayIndicate:(CGContextRef)context at:(int) pos{
    UIGraphicsPushContext(context);
    CGFloat lspec = self.spec;
    CGPoint loc = CGPointMake(self.outside+lspec*I(pos), self.outside+lspec*J(pos));
    CGFloat radio = 2;
    if (self.lastPlayPointColor==BLACK) {
        [[UIColor whiteColor]setFill];
    }else{
        [[UIColor blackColor]setFill];
    }
    //[[[UIColor alloc]initWithRed:0 green:0.6 blue:0.8 alpha:1] setFill] ;
    CGContextFillEllipseInRect(context,CGRectMake(loc.x-radio, loc.y-radio,radio*2 ,radio*2) );
    UIGraphicsPopContext() ;
}
-(void)drawPieces:(CGContextRef) context{
    UIGraphicsPushContext(context);
    CGFloat lspec = self.spec;
    for (int x=0; x<board_size; x++) {
        for (int y=0; y<board_size; y++) {
            int color = self.boardToShow[POS(x, y)];
            [self drawPiece:context withColor:color at:CGPointMake(self.outside+lspec*x, self.outside+lspec*y)];
        }
    }
    
    
    UIGraphicsPopContext();
}
-(void)drawStepHint:(CGContextRef)context{
    UIGraphicsPushContext(context);
    CGFloat lspec = self.spec;
    for (int x=0; x<board_size; x++) {
        for (int y=0; y<board_size; y++) {
            int stepCount = self.boardShowStepHint[POS(x, y)];
            if (stepCount==0) {
                continue;
            }
            NSString *number = [NSString stringWithFormat:@"%d",stepCount];
            [self drawStepHint:context withStepCount: number at:CGPointMake(self.outside+lspec*x, self.outside+lspec*y)];
        }
    }
    UIGraphicsPopContext();
}

-(void)drawStepHint:(CGContextRef)context withStepCount:(NSString *)number at:(CGPoint)loc{
    UIGraphicsPushContext(context);
    CGFloat radio =((self.frame.size.width/668)*PIECE_RADIO);
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary* attributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName:
                                     [UIColor colorWithRed:((float) 128/ 255.0f)
                                                     green:((float) 128/ 255.0f)
                                                      blue:((float) 128/ 255.0f)
                                                     alpha:1.0f]};
    
    [number drawInRect:CGRectMake(loc.x-radio, loc.y-radio/2,radio*2 ,radio*2) withAttributes:attributes];
    
    UIGraphicsPopContext();
}
-(void)drawLabelHint:(CGContextRef)context withStepCount:(NSString *)number at:(CGPoint)loc {
    UIGraphicsPushContext(context);
    CGFloat radio =((self.frame.size.width/668)*PIECE_RADIO);
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary* attributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                 NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter"size:20],
                                 NSForegroundColorAttributeName:
                                     [UIColor colorWithRed:14/255.0 green:133/255.0 blue:251/255.0 alpha:1.0]};
    
    [number drawInRect:CGRectMake(loc.x-radio, loc.y-radio,radio*2 ,radio*2) withAttributes:attributes];
    
    UIGraphicsPopContext();
}

-(void)drawPiece:(CGContextRef)context withColor:(int)color at:(CGPoint)loc{
    UIGraphicsPushContext(context);
    CGImageRef imageRef;
    switch (color) {
        case EMPTY:
            return;
        case BLACK:
            //[[UIColor blackColor]setFill] ;
            imageRef = self.blackPiece.CGImage;
            break;
        case WHITE:
            //[[UIColor whiteColor]setFill] ;
            imageRef = self.whitePiece.CGImage;
            break;
        default:
            return ;
    }
    CGFloat radio =((self.frame.size.width/668)*PIECE_RADIO);
    CGContextDrawImage(context,  CGRectMake(loc.x-radio, loc.y-radio,radio*2 ,radio*2), imageRef);
//    CGContextFillEllipseInRect(context, CGRectMake(loc.x-radio, loc.y-radio,radio*2 ,radio*2));
    UIGraphicsPopContext();
}
-(void)drawBoard:(CGContextRef)context{
    UIGraphicsPushContext(context);
    CGImageRef imgRef = self.board.CGImage;
    CGContextDrawImage(context,  CGRectMake(0, 0,self.frame.size.width ,self.frame.size.width), imgRef);
    UIGraphicsPopContext();
}
-(void)drawBoardWidth:(CGFloat)width andSpecToSide:(CGFloat)spec onContext:(CGContextRef) context{
    CGContextSetLineWidth(context, width);
    CGContextBeginPath(context);
    [[UIColor grayColor]setStroke];
    CGFloat boardWidth =self.frame.size.width-spec;
    CGContextMoveToPoint(context, spec, spec);
    CGContextAddLineToPoint(context, spec,boardWidth);
    CGContextAddLineToPoint(context, boardWidth, boardWidth);
    CGContextAddLineToPoint(context, boardWidth, spec);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
}
-(void)sync{
    memcpy(self.boardToShow, board, sizeof(board));
}
-(void )showStepHint{
    self.needShowStepHint=YES;
    [self setNeedsDisplay];
}
-(void)closeStepHint{
    self.needShowStepHint=NO;
    [self setNeedsDisplay];
}
-(void)cleanStepHint{
    self.curStepCount=0;
    memset(self.boardShowStepHint,0,BOARDSIZE*sizeof(int));
}
-(void)changeStepHint{
    if (self.needShowStepHint) {
        [self closeStepHint];
    }else{
        [self showStepHint];
    }
}
-(void)addLabel:(NSArray*)labelMoves{
    [self.labelMoveArray addObjectsFromArray:labelMoves];
    [self setNeedsDisplay];
}
-(void)clearMark{
    [self.labelMoveArray removeAllObjects];
}


@end
