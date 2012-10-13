//
//  ADLPostItView.m
//  iParapheur
//
//  Created by Emmanuel Peralta on 08/10/12.
//
//

#import "ADLPostItView.h"

@implementation ADLPostItView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    {
        [[UIColor yellowColor] setFill];
        CGContextFillRect(context, self.frame);
        
    }
    UIGraphicsPopContext();

}


@end
