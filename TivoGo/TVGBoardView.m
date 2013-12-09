//
//  TVGBoardView.m
//  TivoGo
//
//  Created by BiXiaopeng on 13-12-3.
//  Copyright (c) 2013年 BiXiaopeng. All rights reserved.
//

#import "TVGBoardView.h"

@implementation TVGBoardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tapRec =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAt:)];
        NSLog(@"init");
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBoardWidth:4 andSpecToSide:10 onContext:context];
    [self drawBoardWidth:2 andSpecToSide:16 onContext:context];
    //draw grid
    CGFloat startX = 17;
    CGFloat startY = 17;
    CGFloat lineSize = self.frame.size.width-startX;
    CGFloat spec = (lineSize-startX)/18;
    CGFloat curStart,sumSpec;
    for (int i=1; i<18; i++) {
        sumSpec = i*spec;
        CGContextBeginPath(context);
        curStart = startY+sumSpec;
        CGContextMoveToPoint(context, startX,curStart );
        CGContextAddLineToPoint(context, lineSize, curStart);
        CGContextDrawPath(context, kCGPathStroke);
        CGContextBeginPath(context);
        curStart = startX+sumSpec;
        CGContextMoveToPoint(context, curStart,startY );
        CGContextAddLineToPoint(context, curStart, lineSize);
        CGContextDrawPath(context, kCGPathStroke);
    }
    //draw star
    
    //[[UIColor grayColor]setFill];
    CGFloat starSpec = startX+3*spec-3;
    CGFloat starDis = 6*spec;
    int x,y;
    CGFloat pX,pY;
    for (int i=0; i<9; i++) {
        x=i/3;
        y=i%3;
        pX=starSpec+x*starDis;
        pY=starSpec+y*starDis;
        CGContextFillEllipseInRect(context, CGRectMake(pX, pY, 6, 6));
    }
    
    
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
- (IBAction)tapAt:(UITapGestureRecognizer *)sender{
    NSLog(@"tapd");
}


@end
