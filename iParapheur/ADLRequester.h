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

@property (nonatomic, retain) id<ADLParapheurWallDelegateProtocol> delegate;


-(void) downloadDocumentAt:(NSString*)path;
+(ADLRequester *) sharedRequester;
@end
