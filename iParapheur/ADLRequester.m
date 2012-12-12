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
@synthesize lockApi = _lockApi;
@synthesize lockDoc = _lockDoc;

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
        apiQueue.maxConcurrentOperationCount = 5;
        apiQueue.name = @"API Queue";
        _lockApi = [[NSRecursiveLock alloc] init];
        _lockDoc = [[NSRecursiveLock alloc] init];
    }
    return self;
}

-(void) downloadDocumentAt:(NSString*)path {
    [_lockDoc lock];
    
    // clear download queue.
    // XXX this shouldn't bug the user with messages !
    [downloadQueue cancelAllOperations];
    [downloadQueue waitUntilAllOperationsAreFinished];

    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    ADLAPIOperation *downloadOperation = [[ADLAPIOperation alloc] initWithDocumentPath:path andCollectivityDef:def];
    downloadOperation.delegate = _delegate;
    [downloadQueue addOperation:downloadOperation];
    [downloadOperation release];
    
    [_lockDoc unlock];
}

-(void) request:(NSString*)request andArgs:(NSDictionary*)args {
    [_lockApi lock];
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    ADLAPIOperation *apiRequestOperation = [[ADLAPIOperation alloc] initWithRequest:request withArgs:args andCollectivityDef:def];
    apiRequestOperation.delegate = _delegate;
    [apiQueue addOperation:apiRequestOperation];
    [apiRequestOperation release];
    
    [_lockApi unlock];
}

@end
