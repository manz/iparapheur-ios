//
//	ReaderThumbRender.m
//	Reader v2.5.6
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderThumbRender.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbView.h"
#import "CGPDFDocument.h"

#import <ImageIO/ImageIO.h>

@implementation ReaderThumbRender

//#pragma mark Properties

//@synthesize ;

#pragma mark ReaderThumbRender instance methods

- (id)initWithRequest:(ReaderThumbRequest *)object
{
	if ((self = [super initWithGUID:object.guid])) {
		request = object;
	}
	return self;
}

- (void)dealloc
{
    [super dealloc];
	request.thumbView.operation = nil;
	request = nil;
}

- (NSURL *)thumbFileURL
{
	DXLog(@"");
	
	NSFileManager *fileManager = [NSFileManager new];
	NSString *cachePath = [ReaderThumbCache thumbCachePathForGUID:request.guid];
	[fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:NULL];
	NSString *fileName = [NSString stringWithFormat:@"%@.png", request.thumbName];
	
	return [NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:fileName]];
}

- (void)main
{
	DXLog(@"");
	
	if (self.isCancelled == YES) {
		return;
	}
	
	CFURLRef fileURL = (CFURLRef)request.fileURL;
	CGImageRef imageRef = NULL;
	NSInteger page = request.thumbPage;
	NSString *password = request.password;
	CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateX(fileURL, password);
	if (thePDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
	{
		CGPDFPageRef thePDFPageRef = CGPDFDocumentGetPage(thePDFDocRef, page);
		if (thePDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
		{
			CGFloat thumb_w = request.thumbSize.width; // Maximum thumb width
			CGFloat thumb_h = request.thumbSize.height; // Maximum thumb height
			
			// calculate dimensions
			CGRect cropBoxRect = CGPDFPageGetBoxRect(thePDFPageRef, kCGPDFCropBox);
			CGRect mediaBoxRect = CGPDFPageGetBoxRect(thePDFPageRef, kCGPDFMediaBox);
			CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
			
			NSInteger pageRotate = CGPDFPageGetRotationAngle(thePDFPageRef);
			CGFloat page_w = 0.0f;
			CGFloat page_h = 0.0f;
			switch (pageRotate) {
				default:
				case 0: case 180: // 0 and 180 degrees
				{
					page_w = effectiveRect.size.width;
					page_h = effectiveRect.size.height;
					break;
				}
					
				case 90: case 270: // 90 and 270 degrees
				{
					page_h = effectiveRect.size.width;
					page_w = effectiveRect.size.height;
					break;
				}
			}
			
			CGFloat scale_w = (thumb_w / page_w);
			CGFloat scale_h = (thumb_h / page_h);
			
			CGFloat scale = 0.0f;
			if (page_h > page_w) {
				scale = ((thumb_h > thumb_w) ? scale_w : scale_h); // Portrait
			}
			else {
				scale = ((thumb_h < thumb_w) ? scale_h : scale_w); // Landscape
			}
			
			NSInteger target_w = (page_w * scale);
			NSInteger target_h = (page_h * scale);
			
			if (target_w % 2) target_w--;
			if (target_h % 2) target_h--; // Even
			
			target_w *= request.scale;
			target_h *= request.scale;
			
			// draw into bitmap context and pull the image
			CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
			CGBitmapInfo bmi = (kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
			CGContextRef context = CGBitmapContextCreate(NULL, target_w, target_h, 8, 0, rgb, bmi);
			if (context != NULL) {
				CGRect thumbRect = CGRectMake(0.0f, 0.0f, target_w, target_h);
				
				CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
				CGContextFillRect(context, thumbRect);
				CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(thePDFPageRef, kCGPDFCropBox, thumbRect, 0, true)); // Fit rect
				CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
				CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
				
				// Render the PDF page into the custom CGBitmap context and pull the image
				CGContextDrawPDFPage(context, thePDFPageRef);
				imageRef = CGBitmapContextCreateImage(context);
				
				CGContextRelease(context);
			}
			CGColorSpaceRelease(rgb);
		}
		CGPDFDocumentRelease(thePDFDocRef);
	}
	
	// Create UIImage from CGImage and show it, then save thumb as PNG
	if (imageRef != NULL) {
		UIImage *image = [UIImage imageWithCGImage:imageRef scale:request.scale orientation:0];
		[[ReaderThumbCache sharedInstance] setObject:image forKey:request.cacheKey]; // Update cache
		
		// Show the image in the target thumb view on the main thread
		if (!self.isCancelled) {
			ReaderThumbView *thumbView = request.thumbView;
			NSUInteger targetTag = request.targetTag;
			
			// Queue image show on main thread
			dispatch_async(dispatch_get_main_queue(), ^{
				if (thumbView.targetTag == targetTag) {
					[thumbView showImage:image];
				}
			});
		}
		
		CFURLRef thumbURL = (CFURLRef)[self thumbFileURL]; // Thumb cache path with PNG file name URL
		CGImageDestinationRef thumbRef = CGImageDestinationCreateWithURL(thumbURL, (CFStringRef)@"public.png", 1, NULL);
		
		// Write the thumb image file out to the thumb cache directory
		if (thumbRef != NULL) {
			CGImageDestinationAddImage(thumbRef, imageRef, NULL);
			CGImageDestinationFinalize(thumbRef);
			CFRelease(thumbRef);
		}
		
		CGImageRelease(imageRef);
	}
}


@end
