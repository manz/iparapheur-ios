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
//  ADLAnnotationView.m
//  testDrawing
//

#import "ADLAnnotationView.h"
#import "ADLCloseButton.h"
#import "ADLPostitView.h"
#import "ADLPostItButton.h"
#import "ADLDrawingView.h"

#define SHOW_RULES 0

@implementation ADLAnnotationView

@synthesize selected = _selected;
@synthesize annotationModel = _annotationModel;
@synthesize postItView = _postItView;
@synthesize drawingView = _drawingView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.clearsContextBeforeDrawing = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor clearColor];
        
        
        _selected = NO;
        
        /* Cut here to disable _close button */
        CGRect buttonFrame = frame;

        buttonFrame.origin.x = 0;
        buttonFrame.origin.y = 0;
        buttonFrame.size.width = 24;
        buttonFrame.size.height = 24;
        
        _close = [[ADLCloseButton alloc] initWithFrame:buttonFrame];
        
        [_close addTarget:self action:@selector(closeButtonHitted) forControlEvents:UIControlEventTouchDown];
        
        [_close setHidden:YES];
        [_close setNeedsDisplay];
        
        
        CGRect postitFrame = CGRectMake(CGRectGetWidth(frame) - 24.0f, 0.0f, 24.0f ,24.0f);
        
        _postit = [[ADLPostItButton alloc] initWithFrame:postitFrame];
       // [_postit setFrame:postitFrame];
        [_postit addTarget:self action:@selector(postItButtonHitted) forControlEvents:UIControlEventTouchDown];
        [_postit setHidden:YES];
        
        [self addSubview:_close];
        [self addSubview:_postit];
        
        _annotationModel = [[ADLAnnotation alloc] init];

        
//disable the shadowlayer for now it's to consuming
#if 0
        if ([self.layer respondsToSelector:@selector(setShadowOffset:)])
			self.layer.shadowOffset = CGSizeMake(0.25, 0.25);
        
        if ([self.layer respondsToSelector:@selector(setShadowColor:)])
			self.layer.shadowColor = [[UIColor blackColor] CGColor];
        
		if ([self.layer respondsToSelector:@selector(setShadowRadius:)])
			self.layer.shadowRadius = 2;
        
		if ([self.layer respondsToSelector:@selector(setShadowOpacity:)])
			self.layer.shadowOpacity = 0.75;
#endif
        
        
    }
    return self;
}

-(void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGRect postitFrame = CGRectMake(CGRectGetWidth(frame) - 24.0f, 0.0f, 24.0f ,24.0f);
    [_postit setFrame:postitFrame];
    
}

-(id)initWithAnnotation:(ADLAnnotation*)a {
    CGRect frame = [a rect];
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.clearsContextBeforeDrawing = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor clearColor];
        
        
        _selected = NO;
        
        /* Cut here to disable _close button */
        CGRect buttonFrame = frame;
        
        buttonFrame.origin.x = 0;
        buttonFrame.origin.y = 0;
        buttonFrame.size.width = 24;
        buttonFrame.size.height = 24;
        
        _close = [[ADLCloseButton alloc] initWithFrame:buttonFrame];
        
        [_close addTarget:self action:@selector(closeButtonHitted) forControlEvents:UIControlEventTouchDown];
        
        [_close setHidden:YES];
        [_close setNeedsDisplay];
        
        
        CGRect postitFrame = CGRectMake(CGRectGetWidth(frame) - 24.0f, 0.0f, 24.0f ,24.0f);
        
        _postit = [[ADLPostItButton alloc] initWithFrame:postitFrame];
        [_postit addTarget:self action:@selector(postItButtonHitted) forControlEvents:UIControlEventTouchDown];
        [_postit setHidden:YES];
        
        [self addSubview:_close];
        [self addSubview:_postit];
        
        
        //disable the shadowlayer for now it's to consuming
#if 0
        if ([self.layer respondsToSelector:@selector(setShadowOffset:)])
			self.layer.shadowOffset = CGSizeMake(0.25, 0.25);
        
        if ([self.layer respondsToSelector:@selector(setShadowColor:)])
			self.layer.shadowColor = [[UIColor blackColor] CGColor];
        
		if ([self.layer respondsToSelector:@selector(setShadowRadius:)])
			self.layer.shadowRadius = 2;
        
		if ([self.layer respondsToSelector:@selector(setShadowOpacity:)])
			self.layer.shadowOpacity = 0.75;
#endif
        
        _annotationModel = [a retain];
        
        
    }
    return self;
}

-(void)setSelected:(BOOL)selected {
    _selected = selected;
    [_close setHidden:!_selected];
    [_postit setHidden:!_selected];
    ADLPostItView *postIt = _postItView;
    
    if (postIt != nil && selected == NO) {
        [postIt setHidden:YES];
        [postIt removeFromSuperview];
        [((ADLDrawingView*)[self superview]) updateAnnotation:_annotationModel];
        _postItView = nil;
        //[postIt release];
    }
}

-(BOOL)isResizing {
    return !CGPointEqualToPoint(_anchor, CGPointZero);
}

/* notify when removed */

- (void)closeButtonHitted {
    if ([_annotationModel uuid] != nil) {
        [_drawingView removeAnnotation:_annotationModel];
    }
    [self removeFromSuperview];
}

- (void)postItButtonHitted {
    ADLPostItView *postit = [[ADLPostItView alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self frame]),CGRectGetMinY([self frame ]),100, 100)];
 
    [postit setAnnotationModel: [self annotationModel]];
    
    CGRect clippedFrame = [_drawingView clipRectInView:[postit frame]];
    [postit setFrame:clippedFrame];
    
    _postItView = postit;
    [_postItView setContentScaleFactor:[self contentScaleFactor]];
    [[self superview] addSubview:postit];
    
}

// Override setContetScaleFactor to apply it to the close button;
-(void)setContentScaleFactor:(CGFloat)contentScaleFactor {
    [super setContentScaleFactor:contentScaleFactor];
    [_close setContentScaleFactor:contentScaleFactor];
    [_postit setContentScaleFactor:contentScaleFactor];
}


-(void)drawHandle {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    {
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIGraphicsPushContext(context);
    {
        CGRect rect = self.bounds;
        
#if SHOW_RULES
        [[UIColor redColor] setStroke];
        
        CGContextStrokeRect(context, rect);
#endif
        
        
        [[UIColor yellowColor] setFill];
        
        CGRect annotRect = CGRectInset(rect, 12, 12);;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:annotRect cornerRadius:10.0f];
        /*
        if (_selected) {
            CGContextFillRect(context, CGRectMake(CGRectGetMaxX(self.bounds)-54, CGRectGetMaxX(self.bounds)-45, 45, 45));
        }
        */
        path.lineWidth = 4;
        
        [[UIColor yellowColor] setFill];
        //[path fill];

        [[UIColor purpleColor] setStroke];
        [path stroke];
        
    }
    UIGraphicsPopContext();
    
}

-(CGFloat)distanceBetween:(CGPoint)p and:(CGPoint)q {
    CGFloat dx = q.x - p.x;
    CGFloat dy = q.y - p.y;
    
    return sqrtf(dx*dx + dy*dy);
}

-(CGPoint)anchorForTouchLocation:(CGPoint) touchPoint {
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(self.frame) , CGRectGetMaxY(self.frame));

    if ([self distanceBetween:touchPoint and:bottomRight] < kFingerSize) {
        return bottomRight;
    }
    
    return CGPointZero;
}

-(BOOL)isInHandle:(CGPoint)touchPoint {
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(self.frame) , CGRectGetMaxY(self.frame));
    
    return [self distanceBetween:touchPoint and:bottomRight] < kFingerSize;
}

-(void)refreshModel {
    [_annotationModel setRect:[self frame]];
}



@end
