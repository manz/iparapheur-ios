//
//  ADLPostItView.h
//  iParapheur
//
//  Created by Emmanuel Peralta on 08/10/12.
//
//

#import <UIKit/UIKit.h>
#import "ADLAnnotation.h"

@interface ADLPostItView : UIView

@property (nonatomic, retain) ADLAnnotation *annotationModel;
@property (nonatomic, retain) UILabel *label;
@end
