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

-(void) downloadDocumentAt:(NSString*)path delegate:(id<ADLParapheurWallDelegateProtocol>)delegate {
    [_lockDoc lock];
    
    // clear download queue.
    // XXX this shouldn't bug the user with messages !
    [downloadQueue cancelAllOperations];
    [downloadQueue waitUntilAllOperationsAreFinished];

    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    ADLAPIOperation *downloadOperation = [[ADLAPIOperation alloc] initWithDocumentPath:path andCollectivityDef:def delegate:delegate];
    [downloadQueue addOperation:downloadOperation];
    [downloadOperation release];
    //[def release];
    [_lockDoc unlock];
}

-(NSData *) downloadDocumentNow: (NSString*)path{
    [downloadQueue cancelAllOperations];

    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    ADLAPIOperation *downloadOperation = [[ADLAPIOperation alloc] initWithDocumentPath:path andCollectivityDef:def delegate:nil];
    [downloadQueue addOperation:downloadOperation];
    
    [downloadQueue waitUntilAllOperationsAreFinished];
    
    NSData *documentData = [[downloadOperation receivedData] copy];
    [downloadOperation release];

    return documentData;
}

-(void) request:(NSString*)request andArgs:(NSDictionary*)args delegate:(id<ADLParapheurWallDelegateProtocol>)delegate {
    [_lockApi lock];
    
    NSLog(@"%@", request);
    NSLog(@"%@", args);
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    ADLAPIOperation *apiRequestOperation = [[ADLAPIOperation alloc] initWithRequest:request withArgs:args andCollectivityDef:def delegate:delegate];

    [apiQueue addOperation:apiRequestOperation];

    [apiRequestOperation release];
    
    [_lockApi unlock];
}

@end
