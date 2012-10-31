//
//  ADLPostItView.h
//  iParapheur
//
//  Created by Emmanuel Peralta on 08/10/12.
//
//

#import <UIKit/UIKit.h>
#import "ADLAnnotation.h"

@interface ADLPostItView : UIView<UITextViewDelegate>

@property (nonatomic, retain) ADLAnnotation *annotationModel;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UITextView *textView;
@end
