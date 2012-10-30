//
//  ADLPostItView.m
//  iParapheur
//
//  Created by Emmanuel Peralta on 08/10/12.
//
//

#import "ADLPostItView.h"

@implementation ADLPostItView
@synthesize annotationModel = _annotationModel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _label = [[UILabel alloc] initWithFrame:[self bounds]];
        [_label setBackgroundColor:[UIColor yellowColor]];
        [_label setLineBreakMode:NSLineBreakByWordWrapping];
        [_label setNumberOfLines:4];
        
                
        
        [self addSubview:_label];
        
        
        
    }
    return self;
}
         
    
-(void) setAnnotationModel:(ADLAnnotation *)annotationModel {
    _annotationModel = annotationModel;
    [_label setText:[annotationModel text]];
    
    UIFont *font = [_label font];
    CGSize withinSize = CGSizeMake(100.0f, FLT_MAX);
    CGSize size = [[annotationModel text] sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    size.width = 100.0f;
    size.height = size.height > 100.0f ? size.height : 100.0f;
    
    CGRect myFrame = [self frame];
    
    myFrame.size.width = size.width;
    myFrame.size.height = size.height;
    
    myFrame = CGRectInset(myFrame, -15, -15);
    [_label setFrame: CGRectMake(15.0f, 15.0f, size.width, size.height)];
    [self setFrame:myFrame];

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
#if 0
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    {
        [[UIColor yellowColor] setFill];
        CGContextFillRect(context, self.bounds);
        [[UIColor blackColor] setStroke];
        
       /* CGContextSelectFont (context, // 3
                             "Helvetica-Bold",
                             12,
                             kCGEncodingMacRoman);*/
       // CGContextScaleCTM(context, 1, -1);
        
        CGContextTranslateCTM(context, 0.0f, CGRectGetHeight(self.frame));
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
        CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
        CGContextSelectFont(context, "Helvetica", 12, kCGEncodingMacRoman);
        CGContextSetTextDrawingMode(context, kCGTextFill);
        CGContextSetTextPosition(context, 0.0f, 0.0f);
        
        CGContextShowText(context, [[_annotationModel text] UTF8String], strlen([[_annotationModel text] UTF8String]));
        
        
        //CGContextSetCharacterSpacing (context, 10); // 4
        //CGContextSetTextDrawingMode (context, kCGTextFillStroke); // 5

        
        //CGContextShowTextAtPoint(context, 0, 0, "Quartz 2D", 12);
        
    }
    UIGraphicsPopContext();

}
#endif


@end
