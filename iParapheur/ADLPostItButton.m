//
//  ADLPostItButton.m
//  iParapheur
//
//  Created by Emmanuel Peralta on 30/10/12.
//
//

#import "ADLPostItButton.h"

@implementation ADLPostItButton

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		CGFloat radius = self.bounds.size.width / 2;
		CGFloat borderWidth = self.bounds.size.width / 10;
        
		self.layer.backgroundColor = [[UIColor yellowColor] CGColor];
		self.layer.borderColor = [[UIColor whiteColor] CGColor];
		self.layer.borderWidth = borderWidth;
		self.layer.cornerRadius = radius;
        
		if ([self.layer respondsToSelector:@selector(setShadowOffset:)])
			self.layer.shadowOffset = CGSizeMake(0.25, 0.25);
        
		if ([self.layer respondsToSelector:@selector(setShadowColor:)])
			self.layer.shadowColor = [[UIColor blackColor] CGColor];
        
		if ([self.layer respondsToSelector:@selector(setShadowRadius:)])
			self.layer.shadowRadius = borderWidth;
        
		if ([self.layer respondsToSelector:@selector(setShadowOpacity:)])
			self.layer.shadowOpacity = 0.75;
        
        
		[self setNeedsDisplay];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(ctx, true);
    
	CGFloat xsize = self.bounds.size.width / 6;
	CGFloat borderWidth = self.bounds.size.width / 10;
    
	CGContextSaveGState(ctx);
    
	CGContextSetLineCap(ctx, kCGLineCapRound);
	CGContextSetLineWidth(ctx, borderWidth);
	CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    
    //CGContextSetFillColorWithColor(ctx, [[UIColor yellowColor] CGColor]);
    /*
    CGFloat width = self.bounds.size.width;
	CGPoint start1 = CGPointMake(width / 2 - xsize, width / 2 - xsize);
	CGPoint end1 = CGPointMake(width / 2 + xsize, width / 2 + xsize);
	CGPoint start2 = CGPointMake(width / 2 + xsize, width / 2 - xsize);
	CGPoint end2 = CGPointMake(width / 2 - xsize, width / 2 + xsize);
    
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, start1.x, start1.y);
	CGContextAddLineToPoint(ctx, end1.x, end1.y);
	CGContextStrokePath(ctx);
    
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, start2.x, start2.y);
	CGContextAddLineToPoint(ctx, end2.x, end2.y);
	CGContextStrokePath(ctx);*/
    
	CGContextRestoreGState(ctx);
}


@end
