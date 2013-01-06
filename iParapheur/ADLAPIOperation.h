//
//  ADLAPIDocumentOperation.h
//  iParapheur
//
//  Created by Emmanuel Peralta on 10/12/12.
//
//

#import <Foundation/Foundation.h>
#import "ADLParapheurWallDelegateProtocol.h"
#import "ADLCollectivityDef.h"
#import "JSONKit.h"


@interface ADLAPIOperation : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    BOOL downloadingDocument;
    NSURLConnection *_connection;
}
@property (nonatomic, retain) NSString *documentPath;
@property (nonatomic, retain) NSString *request;
@property (nonatomic, retain) NSDictionary *args;

@property(readonly) BOOL isExecuting;
@property(readonly) BOOL isFinished;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, retain) ADLCollectivityDef* collectivityDef;
@property (nonatomic, retain) NSObject<ADLParapheurWallDelegateProtocol> *delegate;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;



-(id)initWithDocumentPath:(NSString *)documentPath andCollectivityDef:(ADLCollectivityDef*)def delegate:(id<ADLParapheurWallDelegateProtocol>)delegate;
-(id)initWithRequest:(NSString*)request withArgs:(NSDictionary*)args andCollectivityDef:(ADLCollectivityDef*)def delegate:(id<ADLParapheurWallDelegateProtocol>)delegate;

/*
-(BOOL) isConcurrent;
-(BOOL) isExecuting;
-(BOOL) isFinished;
-(BOOL) isCancelled;
-(BOOL) isReady;
 */
@end


