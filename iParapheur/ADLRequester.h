//
//  ADLRequester.h
//  iParapheur
//
//  Created by Emmanuel Peralta on 10/12/12.
//
//

#import <Foundation/Foundation.h>
#import "ADLParapheurWallDelegateProtocol.h"

@interface ADLRequester : NSObject {
    NSOperationQueue *downloadQueue;
    NSOperationQueue *apiQueue;
    
    
}

@property (nonatomic, retain, strong) id<ADLParapheurWallDelegateProtocol> delegate;

@property (nonatomic, retain) NSRecursiveLock* lockApi;
@property (nonatomic, retain) NSRecursiveLock* lockDoc;

-(void) downloadDocumentAt:(NSString*)path;
-(void) request:(NSString*)request andArgs:(NSDictionary*)args;

+(ADLRequester *) sharedRequester;
@end
