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
//  ADLCloseButton.m
//  testDrawing
//


#import "ADLCloseButton.h"


@implementation ADLCloseButton

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		CGFloat radius = self.bounds.size.width / 2;
		CGFloat borderWidth = self.bounds.size.width / 10;
        
		self.layer.backgroundColor = [[UIColor blackColor] CGColor];
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
	CGContextStrokePath(ctx);
    
	CGContextRestoreGState(ctx);
}

@end
