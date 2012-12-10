//
//  ADLRequester.m
//  iParapheur
//
//  Created by Emmanuel Peralta on 10/12/12.
//
//

#import "ADLRequester.h"
#import "ADLAPIOperation.h"

@implementation ADLRequester

@synthesize delegate = _delegate;

static ADLRequester *sharedRequester = nil;

+ (ADLRequester *)sharedRequester {
    if (sharedRequester == nil) {
        sharedRequester = [[super allocWithZone:NULL] init];
    }
    return sharedRequester;
}

-(id)init {
    if (self = [super init]) {
        downloadQueue = [[NSOperationQueue alloc] init];
        downloadQueue.name = @"Download Queue";
        downloadQueue.maxConcurrentOperationCount = 1;
        
        apiQueue = [[NSOperationQueue alloc] init];
        apiQueue.name = @"API Queue";
    }
    return self;
}

-(void) downloadDocumentAt:(NSString*)path {
    // clear download queue.
    // XXX this shouldn't bug the user with messages !
    [downloadQueue cancelAllOperations];
    
    
    NSLog(@"begin download");
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    
    ADLAPIOperation *downloadOperation = [[ADLAPIOperation alloc] initWithDocumentPath:path andCollectivityDef:def];
    downloadOperation.delegate = _delegate;
    
    [downloadQueue addOperation:downloadOperation];
    [downloadOperation release];
}

-(void) request:(NSString*)requestPath andArgs:(NSDictionary*)args {
    
    //ADLAPIOperation *apiRequestOperation = [[ADLAPIOperation alloc] initWithA]
    
}


@end
