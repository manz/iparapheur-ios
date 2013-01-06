//
//  ADLRequester.h
//  iParapheur
//
//  Created by Emmanuel Peralta on 10/12/12.
//
//

#import <Foundation/Foundation.h>
#import "ADLParapheurWallDelegateProtocol.h"
#import "ADLAPIRequests.h"

@interface ADLRequester : NSObject {
    NSOperationQueue *downloadQueue;
    NSOperationQueue *apiQueue;
}

@property (nonatomic, retain) NSRecursiveLock* lockApi;
@property (nonatomic, retain) NSRecursiveLock* lockDoc;

+(ADLRequester *) sharedRequester;

-(void) downloadDocumentAt:(NSString*)path delegate:(id<ADLParapheurWallDelegateProtocol>)delegate;
-(void) request:(NSString*)request andArgs:(NSDictionary*)args delegate:(id<ADLParapheurWallDelegateProtocol>)delegate;
-(NSData *) downloadDocumentNow: (NSString*)path;

@end
