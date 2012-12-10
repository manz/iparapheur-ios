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

@interface ADLAPIOperation : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    BOOL downloadingDocument;
}
@property (nonatomic, retain) NSString *documentPath;
@property (nonatomic, retain) NSString *request;
@property (nonatomic, retain) NSDictionary *args;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, retain) ADLCollectivityDef* collectivityDef;
@property (nonatomic, retain) id<ADLParapheurWallDelegateProtocol> delegate;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;


-(id)initWithDocumentPath:(NSString *)documentPath andCollectivityDef:(ADLCollectivityDef*)def;
-(id)initWithRequest:(NSString*)request withArgs:(NSDictionary*)args andCollectivityDef:(ADLCollectivityDef*)def;
@end


