//
//  ADLAnnotation.m
//  iParapheur
//
//  Created by Emmanuel Peralta on 09/10/12.
//
//

#import "ADLAnnotation.h"

@implementation ADLAnnotation
@synthesize author = _author;
@synthesize uuid = _uuid;
@synthesize editable = _editable;
@synthesize text = _text;
@synthesize rect = _rect;

-(id) init {
    if ((self = [super init])) {
    }
    return self;
}

-(id) initWithAnnotationDict:(NSDictionary *)annotation {
    if (self = [super init]) {
        _author = [annotation objectForKey:@"author"];
        _uuid = [annotation objectForKey:@"uuid"];
        _rect = [self rectWithDict:[annotation objectForKey:@"rect"]];
//        _editable = [annotation objectForKey:@"editable"];
        _text = [annotation objectForKey:@"text"];
        
    }
    return self;
}

/* compute the rect with pixels coordoniates */
-(CGRect)rectWithDict:(NSDictionary*)dict {
    NSDictionary *topLeft = [dict objectForKey:@"topLeft"];
    NSDictionary *bottomRight = [dict objectForKey:@"bottomRight"];
    
    NSNumber *x = [topLeft objectForKey:@"x"];
    NSNumber *y = [topLeft objectForKey:@"y"];
    
    NSNumber *x1 = [bottomRight objectForKey:@"x"];
    NSNumber *y1 = [bottomRight objectForKey:@"y"];
    
    CGRect arect = CGRectMake([x floatValue]  / 150.0f * 72.0f,
                      [y floatValue]  / 150.0f * 72.0f,
                      ([x1 floatValue]  / 150.0f * 72.0f) - ([x floatValue] / 150.0f * 72.0f), // width
                      ([y1 floatValue] / 150.0f * 72.0f) - ([y floatValue] / 150.0f * 72.0f)); // height
    
    return CGRectInset(arect, -14.0f, -14.0f);
    
}


@end
