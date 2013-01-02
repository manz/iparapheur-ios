//
//	ReaderViewController.h
//	Reader v2.5.4
//
//	Created by Julius Oklamcak on 2011-07-01.
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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ReaderDocument.h"
#import "ReaderContentView.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ThumbsViewController.h"

@class ReaderViewController;
@class ReaderMainToolbar;

@protocol ReaderViewControllerDelegate <NSObject>

@optional
- (void)dismissReaderViewController:(ReaderViewController *)viewController;

@end


@interface ReaderViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate,
													ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate,
													ThumbsViewControllerDelegate>
{
@private // Instance variables
	UIPrintInteractionController *printInteraction;
	
	NSInteger currentPage;
	CGSize lastAppearSize;
	BOOL isVisible;
}

@property (nonatomic, unsafe_unretained, readwrite) id <ReaderViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) ReaderDocument *document;

@property (nonatomic, unsafe_unretained, readwrite) id<ADLDrawingViewDataSource> dataSource;

@property (nonatomic, strong) UIScrollView *theScrollView;
@property (nonatomic, strong) ReaderMainToolbar *mainToolbar;
@property (nonatomic, strong) ReaderMainPagebar *mainPagebar;
@property (nonatomic, strong) NSMutableDictionary *contentViews;

@property (nonatomic, readonly, strong) NSDate *lastHideTime;

@property (nonatomic, assign) BOOL annotationsEnabled;

- (id)initWithReaderDocument:(ReaderDocument *)object;

- (void)didAddContentView:(ReaderContentView *)aContentView forPage:(NSInteger)pageNumber;
- (NSData *)documentData;

- (void)updateScrollViewContentViews;

- (Class)classForViewPages;


@end
