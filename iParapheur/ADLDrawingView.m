/*
 * Version 1.1
 * CeCILL Copyright (c) 2012, SKROBS, ADULLACT-projet
 * Initiated by ADULLACT-projet S.A.
 * Developped by SKROBS
 *
 * contact@adullact-projet.coop
 *
 * Ce logiciel est un programme informatique servant à faire circuler des
 * documents au travers d'un circuit de validation, où chaque acteur vise
 * le dossier, jusqu'à l'étape finale de signature.
 *
 * Ce logiciel est régi par la licence CeCILL soumise au droit français et
 * respectant les principes de diffusion des logiciels libres. Vous pouvez
 * utiliser, modifier et/ou redistribuer ce programme sous les conditions
 * de la licence CeCILL telle que diffusée par le CEA, le CNRS et l'INRIA
 * sur le site "http://www.cecill.info".
 *
 * En contrepartie de l'accessibilité au code source et des droits de copie,
 * de modification et de redistribution accordés par cette licence, il n'est
 * offert aux utilisateurs qu'une garantie limitée.  Pour les mêmes raisons,
 * seule une responsabilité restreinte pèse sur l'auteur du programme,  le
 * titulaire des droits patrimoniaux et les concédants successifs.
 *
 * A cet égard  l'attention de l'utilisateur est attirée sur les risques
 * associés au chargement,  à l'utilisation,  à la modification et/ou au
 * développement et à la reproduction du logiciel par l'utilisateur étant
 * donné sa spécificité de logiciel libre, qui peut le rendre complexe à
 * manipuler et qui le réserve donc à des développeurs et des professionnels
 * avertis possédant  des  connaissances  informatiques approfondies.  Les
 * utilisateurs sont donc invités à charger  et  tester  l'adéquation  du
 * logiciel à leurs besoins dans des conditions permettant d'assurer la
 * sécurité de leurs systèmes et ou de leurs données et, plus généralement,
 * à l'utiliser et l'exploiter dans les mêmes conditions de sécurité.
 *
 * Le fait que vous puissiez accéder à cet en-tête signifie que vous avez
 * pris connaissance de la licence CeCILL, et que vous en avez accepté les
 * termes.
 */

//
//  ADLDrawingView.m
//  testDrawing
//

#import "ADLDrawingView.h"
#import "ADLAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ADLDrawingView

@synthesize parentScrollView = _parentScrollView;
@synthesize superScrollView = _superScrollView;
@synthesize dataSource = _dataSource;

@synthesize enabled = _enabled;

@synthesize pageNumber = _pageNumber;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _hittedView = nil;
        _currentAnnotView = nil;
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        /*
         UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
         */
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        
        _longPressGestureRecognizer.cancelsTouchesInView = NO;
        
        [self addGestureRecognizer:_longPressGestureRecognizer];
        
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        // by default disable annotations
        _enabled = YES;
        
        //self.clipsToBounds = YES;
    }
    return self;
}

- (void)awakeFromNib {
    _hittedView = nil;
    _currentAnnotView = nil;
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // CGPoint touchPoint = [gestureRecognizer locationInView:self];
    //    UIView *hitted = [self hitTest:touchPoint withEvent:event];
    
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (_hittedView == nil && _enabled) {
        CGPoint touchPoint = [gestureRecognizer locationInView:self];
        CGRect annotFrame = [self clipRectInView:CGRectMake(touchPoint.x, touchPoint.y, 100, 100)];
        _currentAnnotView = [[ADLAnnotationView alloc] initWithFrame:annotFrame];
        [_currentAnnotView setContentScaleFactor:[_parentScrollView contentScaleFactor]];
        
        [self addSubview:_currentAnnotView];
    }
    else {
        
    }
    
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    
    if (_hittedView != nil && _enabled) {
        [self animateviewOnLongPressGesture:touchPoint];
    }
    
    _hasBeenLongPressed = YES;
    
}



- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (_enabled) {
        UITouch *touch = [[event allTouches] anyObject];
        
        CGPoint touchPoint = [self clipPointToView:[touch locationInView:self]];
        
        UIView *hitted = [self hitTest:touchPoint withEvent:event];
        
        [self unselectAnnotations];
        _hittedView = nil;
        
        
        if (hitted != self) {
            
            //if (_hasBeenLongPressed) {
            _parentScrollView.scrollEnabled = NO;
            _superScrollView.scrollEnabled = NO;
            _hittedView = (ADLAnnotationView*)hitted;
            _origin = hitted.frame.origin;
            _dx = sqrt(pow(_origin.x - touchPoint.x, 2.0));
            _dy = sqrt(pow(_origin.y - touchPoint.y, 2.0));
            _currentAnnotView = nil;
            
            if ([_hittedView isInHandle:[touch locationInView:self]]) {
                _longPressGestureRecognizer.enabled = NO;
            }
            
            [_hittedView setSelected:true];
            [_hittedView setNeedsDisplay];
        }
        else {
            _parentScrollView.scrollEnabled = YES;
            _superScrollView.scrollEnabled = YES;
            _hasBeenLongPressed = NO;
            
        }
    }
}

-(void) unselectAnnotations {
    for (UIView* subview in [self subviews]) {
        if ([subview class] == [ADLAnnotationView class]) {
            ADLAnnotationView *a = (ADLAnnotationView*)subview;
            [a setSelected:NO];
        }
    }
}

-(void)displayAnnotations:(NSArray*)annotations {
    ADLAnnotationView *annotView = nil;
    for (NSDictionary* dict in annotations) {
        CGRect annotRect ;
        annotView = [[ADLAnnotationView alloc] initWithFrame:annotRect];
        [self addSubview:annotView];
    }
}

-(CGRect)convertFromPixelRect:(CGRect)pixelRect {
    return CGRectZero;
}

-(CGRect)convertToPixelRect:(CGRect)uiViewRect {
    return CGRectZero;
}

/*
 -(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
 UITouch *touch = [touches anyObject];
 
 if (_selected) {
 _anchor = [self anchorForTouchLocation:[touch locationInView:self]];
 
 }
 else {
 _selected = YES;
 [self setNeedsDisplay];
 }
 
 }
 */

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_enabled) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [self clipPointToView:[touch locationInView:self]];
        
        if ([_hittedView isInHandle:[touch locationInView:self]]) {
            
            CGRect frame = [_hittedView frame];
            
            frame.size.width = point.x - frame.origin.x;
            frame.size.height = point.y - frame.origin.y;
            _parentScrollView.scrollEnabled = NO;
            _superScrollView.scrollEnabled = NO;
            
            
            
            [_hittedView setFrame:frame];
            [_hittedView setNeedsDisplay];
        }
        else if (_hittedView != nil && _hasBeenLongPressed) {
            CGRect frame = [_hittedView frame];
            
            frame.origin.x = point.x - _dx;
            frame.origin.y = point.y - _dy;
            
            frame = [self clipRectInView:frame];
            
            _parentScrollView.scrollEnabled = NO;
            _superScrollView.scrollEnabled = NO;
            
            [_hittedView setFrame:frame];
        }
        else {
            
            
        }
        [self touchesCancelled:touches withEvent:event];
    }
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_enabled) {
        
        
        UITouch *touch = [touches anyObject];
        
        if (_hasBeenLongPressed) {
            _hasBeenLongPressed = NO;
            [self unanimateView:[touch locationInView:self]];
            
        }
        
        //_hittedView = nil;
        _parentScrollView.scrollEnabled = YES;
        _superScrollView.scrollEnabled = YES;
        _longPressGestureRecognizer.enabled = YES;
    }
    
}

- (CGPoint) clipPointToView:(CGPoint)touch {
    
    CGPoint ret = touch;
    
    if (touch.x < 0) {
        ret.x = 0;
    }
    
    if (touch.x > self.frame.size.width) {
        ret.x = self.frame.size.width;
    }
    
    if (touch.y < 0) {
        ret.y = 0;
    }
    
    if (touch.y > self.frame.size.height) {
        ret.y = self.frame.size.height;
    }
    
    return ret;
    
    
}

-(CGRect)clipRectInView:(CGRect)rect {
    CGRect frame = [self frame];
    CGRect clippedRect = rect;
    
    CGFloat dx= 0.0f;
    CGFloat dy= 0.0f;
    
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(frame)) {
        // overflow
        dx = CGRectGetMaxX(rect) - CGRectGetMaxX(frame);
    }
    
    
    if (CGRectGetMaxY(rect) > CGRectGetMaxY(frame)) {
        dy = CGRectGetMaxY(rect) - CGRectGetMaxY(frame);
    }
    
    clippedRect.origin.x -= dx;
    clippedRect.origin.y -= dy;
    
    clippedRect.origin = [self clipPointToView:clippedRect.origin];
    return clippedRect;
}

-(void) animateviewOnLongPressGesture:(CGPoint)touchPoint {
#define GROW_ANIMATION_DURATION_SECONDS 0.15
	
	NSValue *touchPointValue = [[NSValue valueWithCGPoint:touchPoint] retain];
	[UIView beginAnimations:nil context:touchPointValue];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.1f, 1.1f);
	_hittedView.transform = transform;
	[UIView commitAnimations];
    
}

//- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {

-(void)unanimateView:(CGPoint) touchPoint {
#define MOVE_ANIMATION_DURATION_SECONDS 0.15
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
	_hittedView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
	/*
	 Move the placardView to under the touch.
	 We passed the location wrapped in an NSValue as the context.
	 Get the point from the value, then release the value because we retained it in touchesBegan:withEvent:.
	 */
	//_hittedView.center = touchPoint;
	[UIView commitAnimations];
}


#pragma mark - dataSource

-(void) refreshAnnotations {
    
    for (UIView *a in [self subviews]) {
        [a removeFromSuperview];
    }
    
    if (_dataSource != nil) {
        NSArray *annotations = [self annotationsForPage:_pageNumber];
        
        for (NSDictionary *annotation in annotations) {
            
            ADLAnnotation *annotModel = [[ADLAnnotation alloc] initWithAnnotationDict:annotation];
            
            CGRect annotRect = [annotModel rect];
            
            
            ADLAnnotationView *a = [[ADLAnnotationView alloc] initWithFrame:annotRect];
            [self addSubview:a];
            [a release];
            // get coordinates in pixels
            // getPDFPageSize
            // PDFPageSize * 72dpi
        }
    }
    
}

/*-(void) addAnnotation:(NSDictionary*)annotation {
    if ([_dataSource respondsToSelector:@selector(addAnnotation:)]) {
        
    }
}*/

-(void) updateAnnotation:(ADLAnnotation*)annotation {
    //TODO: implement
    [_dataSource updateAnnotation:annotation forPage:_pageNumber];
}

-(void) addAnnotation:(ADLAnnotation*)annotation {
    [_dataSource addAnnotation:annotation forPage:_pageNumber];
}

-(void) removeAnnotation:(ADLAnnotation*) annotation forPage:(NSUInteger)page {
    [_dataSource removeAnnotation:annotation fromPage:page];
}

-(NSArray*) annotationsForPage:(NSUInteger)page {
    if (_enabled) {
        if ([_dataSource respondsToSelector:@selector(annotationsForPage:)]) {
            return [_dataSource annotationsForPage:page];
        }
    }
    return nil;
}


#pragma mark - Abstract Method

-(CGSize)getPageSize {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}




@end
