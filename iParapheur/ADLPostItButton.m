//
//  ADLPostItButton.m
//  iParapheur
//
//  Created by Emmanuel Peralta on 30/10/12.
//
//

#import "ADLPostItButton.h"

@implementation ADLPostItButton
@synthesize hasText;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		CGFloat borderWidth = self.bounds.size.width / 10;
        
		self.layer.backgroundColor = [[UIColor yellowColor] CGColor];
		self.layer.borderColor = [[UIColor whiteColor] CGColor];
		self.layer.borderWidth = borderWidth;
		//self.layer.cornerRadius = radius;
        
		if ([self.layer respondsToSelector:@selector(setShadowOffset:)])
			self.layer.shadowOffset = CGSizeMake(0.25, 0.25);
        
		if ([self.layer respondsToSelector:@selector(setShadowColor:)])
			self.layer.shadowColor = [[UIColor blackColor] CGColor];
        
		if ([self.layer respondsToSelector:@selector(setShadowRadius:)])
			self.layer.shadowRadius = borderWidth;
        
		if ([self.layer respondsToSelector:@selector(setShadowOpacity:)])
			self.layer.shadowOpacity = 0.75;
        
        hasText = NO;
		[self setNeedsDisplay];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, true);
    
	CGFloat borderWidth = self.bounds.size.width / 10;
    
	CGContextSaveGState(context);
    
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, borderWidth);
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    
    if ([self hasText]) {
        CGContextTranslateCTM(context, 0.0f, CGRectGetHeight(self.frame));
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        CGSize size = [@"Aa" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:CGSizeMake(100.0f, 100.0f) lineBreakMode:UILineBreakModeWordWrap];
        
        CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
        CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
        CGContextSelectFont(context, "Helvetica", 12, kCGEncodingMacRoman);
        CGContextSetTextDrawingMode(context, kCGTextFill);
        CGContextSetTextPosition(context, self.bounds.size.width/2.0f - size.width/2.0f, self.bounds.size.height/2.0f - size.height / 2.0f);
        
        CGContextShowText(context, "Aa", 2);
    }

    
	CGContextRestoreGState(context);
}


@end
