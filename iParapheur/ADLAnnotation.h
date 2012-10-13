//
//  ADLAnnotation.h
//  iParapheur
//
//  Created by Emmanuel Peralta on 09/10/12.
//
//

#import <Foundation/Foundation.h>

@interface ADLAnnotation : NSObject

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic) BOOL editable;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *author;
@property (nonatomic) CGRect rect;


- (id)init;
- (id)initWithAnnotationDict:(NSDictionary*)annotation;

@end
