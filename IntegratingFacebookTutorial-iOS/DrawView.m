//
//  DrawView.m
//  DrawMyFriends
//
//  Created by Lilly Holymushrooms Shen on 7/15/14.
///Users/laitchs/src/fbobjc/Users/mreddlaitchs/IntegratingFacebookTutorial-iOS/IntegratingFacebookTutorial/AppDelegate.h
//

#import "DrawView.h"

const NSInteger kMaxUndoLevel = 39;

@implementation DrawView
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    UIImage *previousImage;
    NSInteger historyLength;
    NSRange pastRange;
    UITouch *initialTouch;
    BOOL moved;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        path = [UIBezierPath bezierPath];
        _brush = 20.0;
        _opacity = .5;
        _color=[[UIColor blackColor] colorWithAlphaComponent:.5];
        _index = 0;
        _drawHistory = [NSMutableArray array];
        [_drawHistory addObject:[NSNull null]];
        
        historyLength = 1;
        pastRange.location = 0;
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];

        path = [UIBezierPath bezierPath];
        _brush=20.0;
        _opacity=.5;
        _color=[[UIColor blackColor] colorWithAlphaComponent:.5];
        _drawHistory=[NSMutableArray array];
        [_drawHistory addObject:[NSNull null]];
        _index=0;
        
        historyLength=1;
        pastRange.location=0;
        
    }
    return self;
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    [incrementalImage drawInRect:rect];
    path.lineCapStyle = kCGLineCapRound;
    [self.color setStroke];
    [self.color setFill];
    [path stroke];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    moved=false;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    ctr = 0;
    UITouch *touch = [touches anyObject];
    initialTouch= [touches anyObject];
    pts[0] = [touch locationInView:self];
    [self.color setStroke];
    [path setLineWidth:self.brush];
    [path addArcWithCenter:pts[0]
                    radius:.1
                startAngle:0.0
                  endAngle:2.0 * M_PI
                 clockwise:NO];
    [path fill];
    UIGraphicsEndImageContext();
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    moved=true;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
        UIGraphicsEndImageContext();
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    
    if (!incrementalImage) // first time; paint background white
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }
    
    
    [incrementalImage drawAtPoint:CGPointZero];
    [self.color setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // make sure the array doesn't get too big :/ otherwise, memory probs
    if(self.index==kMaxUndoLevel){
        pastRange.location=historyLength - kMaxUndoLevel;
        pastRange.length = kMaxUndoLevel;
        self.drawHistory=[[self.drawHistory subarrayWithRange:pastRange] mutableCopy];
        [self.drawHistory addObject:incrementalImage];
        self.index=kMaxUndoLevel;
        historyLength = kMaxUndoLevel + 1;
    }
    
    else
    {
        self.index++;
        pastRange.length=self.index;
        pastRange.location=0;
        
        self.drawHistory = [[self.drawHistory subarrayWithRange:pastRange] mutableCopy];
        [self.drawHistory addObject:incrementalImage];
        historyLength=self.index+1;
    }

    UIGraphicsEndImageContext();
}
- (void)rewind
{
    if (self.index > 0)
    {
     
        self.index--;

        id obj = self.drawHistory[self.index];
        
        if (obj == [NSNull null] || self.index==0)
            incrementalImage=nil;
        else
            incrementalImage=self.drawHistory[self.index];
        [self setNeedsDisplay];
    }
}
-(void)fastForward
{
    if (historyLength > self.index +1)
    {
        
        self.index++;
        id obj = self.drawHistory[self.index];
        if (obj == [NSNull null])
            incrementalImage=nil;
        else
            incrementalImage=self.drawHistory[self.index];
        [self setNeedsDisplay];

    }
}

-(void)clear
{
    incrementalImage=nil;
    if(self.index == kMaxUndoLevel){
        pastRange.location=historyLength - kMaxUndoLevel;
        pastRange.length=kMaxUndoLevel;
        self.drawHistory=[[self.drawHistory subarrayWithRange:pastRange] mutableCopy];
        [self.drawHistory addObject:[NSNull null]];
        self.index=kMaxUndoLevel;
        historyLength= kMaxUndoLevel + 1;
        
    }
    
    else
    {
        self.index++;
        pastRange.length=self.index;
        pastRange.location=0;
        
        self.drawHistory = [[self.drawHistory subarrayWithRange:pastRange] mutableCopy];
        [self.drawHistory addObject:[NSNull null]];
        historyLength=self.index+1;
    }
    [self setNeedsDisplay];
}
-(UIImage *)getDrawing
{
    return incrementalImage;
}
@end
