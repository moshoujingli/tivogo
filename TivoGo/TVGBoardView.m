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
@property (nonatomic)UIImage *blackPiece;
@property (nonatomic)UIImage *whitePiece;
@property (nonatomic)UIImage *board;
@end

@implementation TVGBoardView
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
    self.boardToShow = (Intersection *)calloc(BOARDSIZE,sizeof(Intersection));
    self.board = [UIImage imageNamed:@"Board_pad.png"];
    self.blackPiece = [UIImage imageNamed:@"black_piece.png"];
    self.whitePiece = [UIImage imageNamed:@"white_piece.png"];
}

-(BOOL)setPiece:(int)color at:(int)x and: (int)y{
    NSLog(@"%d,%d this is %d",x,y,BOARD(x, y));
    if (IS_STONE(BOARD(x, y))) {
        NSLog(@"not empty");
        return NO;
    }
    gnugo_play_move(POS(x, y), color);
    self.boardToShow[POS(x, y)]=color;
    if (memcmp(board, self.boardToShow,sizeof(board))) {
        memcpy(self.boardToShow, board, sizeof(board));
    }
    [self setNeedsDisplay];
    return YES;
}
-(void)indicate:(int)color at:(int)x and:(int)y{
    self.indicatePos=CGPointMake(PIECE_OUTSIDE_SPEC+self.spec*x, PIECE_OUTSIDE_SPEC+self.spec*y);
    self.indicateColor=color;
    if (color!=EMPTY) {
        [self setNeedsDisplay];
    }
}

-(void)undo:(int)step{
    undo_move(step);
    memcpy(self.boardToShow, board, sizeof(board));
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBoard:context];
    [self drawPieces:context];
    if (self.indicateColor) {
        [self drawPiece:context withColor:self.indicateColor at:self.indicatePos];
    }
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

//    [self drawBoardWidth:OUT_BOARD_WIDTH andSpecToSide:BASE_OUT_SPEC onContext:context];
//    [self drawBoardWidth:INSIDE_BOARD_WIDTH andSpecToSide:BASE_OUT_SPEC+INSIDE_BOARD_WIDTH+OUT_BOARD_WIDTH onContext:context];
//    //draw grid
//    CGFloat startX = PIECE_OUTSIDE_SPEC;
//    CGFloat startY = PIECE_OUTSIDE_SPEC;
//    CGFloat lineEnd = self.frame.size.width-startX;
//    CGFloat spec = (lineEnd-PIECE_OUTSIDE_SPEC)/(board_size-1);
//    CGFloat curStart,sumSpec;
//    for (int i=1; i<board_size-1; i++) {
//        sumSpec = i*spec;
//        CGContextBeginPath(context);
//        curStart = startY+sumSpec;
//        CGContextMoveToPoint(context, startX,curStart );
//        CGContextAddLineToPoint(context, lineEnd, curStart);
//        CGContextDrawPath(context, kCGPathStroke);
//        CGContextBeginPath(context);
//        curStart = startX+sumSpec;
//        CGContextMoveToPoint(context, curStart,startY );
//        CGContextAddLineToPoint(context, curStart, lineEnd);
//        CGContextDrawPath(context, kCGPathStroke);
//    }
//    //draw star
//    
//    [[UIColor blackColor]setFill];
//    CGFloat starSpec = startX+3*spec-3;
//    CGFloat starDis = 6*spec;
//    int x,y;
//    CGFloat pX,pY;
//    for (int i=0; i<9; i++) {
//        x=i/3;
//        y=i%3;
//        pX=starSpec+x*starDis;
//        pY=starSpec+y*starDis;
//        CGContextFillEllipseInRect(context, CGRectMake(pX, pY, 6, 6));
//    }
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


@end
