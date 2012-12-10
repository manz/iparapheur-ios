//
//  ADLAPIDocumentOperation.m
//  iParapheur
//
//  Created by Emmanuel Peralta on 10/12/12.
//
//

#import "ADLAPIOperation.h"
#import "ADLDocument.h"
#import "Reachability.h"
#import "ADLCredentialVault.h"


@implementation ADLAPIOperation

@synthesize lock = _lock;
@synthesize delegate = _delegate;

+ (void) __attribute__((noreturn)) networkRequestThreadEntryPoint:(id)__unused object {
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

-(id)initWithDocumentPath:(NSString *)documentPath andCollectivityDef:(ADLCollectivityDef*)def {
    if (self = [super init]) {
        _documentPath = documentPath;
        downloadingDocument = YES;
        _collectivityDef = def;
        self.lock = [[NSRecursiveLock alloc] init];
    }
    
    return self;
}

-(id)initWithRequest:(NSString *)request withArgs:(NSDictionary *)args andCollectivityDef:(ADLCollectivityDef*)def {
    if (self = [super init]) {
        _request = request;
        _args = args;
        _collectivityDef = def;
        downloadingDocument = NO;
    }
    return self;
}

-(void)main {
    @autoreleasepool {
        // startDownloading
        [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO];

        
    }
}

-(void)operationDidStart {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability currentReachabilityStatus] == NotReachable) {
        if (_delegate)
            [_delegate didEndWithUnReachableNetwork];
    }
    else {
        
        ADLCredentialVault *vault = [ADLCredentialVault sharedCredentialVault];
        NSString *alf_ticket = [vault getTicketForHost:[_collectivityDef host] andUsername:[_collectivityDef username]];
        NSURL *requestURL = nil;
        
        
        
        if (alf_ticket != nil) {
            if (downloadingDocument) {
                requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://m.%@%@?alf_ticket=%@", [_collectivityDef host], _documentPath, alf_ticket]];
            }
        }
        else {
            NSLog(@"Error while DL/ing the document");
        }
        
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
        [requestURL release];
        
        [request setHTTPMethod:@"GET"];
        
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
        
        [connection start];
        
        _receivedData= [[NSMutableData data] retain];
        
        [request release];
        
    }
}




#pragma mark - Connection Delegate for server trust evaluation.

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (!self.isCancelled) {
        [_delegate performSelectorOnMainThread:@selector(didEndWithUnReachableNetwork:) withObject:nil waitUntilDone:YES];
    }
    
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return NO;
}


- (SecCertificateRef)certificateFromFile:(NSString*)file {
    CFDataRef adullact_g3_ca_data = (CFDataRef)[[NSFileManager defaultManager] contentsAtPath:file];
    
    return SecCertificateCreateWithData (kCFAllocatorDefault, adullact_g3_ca_data);
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge; {
    
#ifndef DEBUG_NO_SERVER_TRUST
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    NSString *adullact_mobile_path = [[NSBundle mainBundle] pathForResource:@"ca_adullact_g3" ofType:@"der"];
    
    SecCertificateRef adullact_mobile = [self certificateFromFile:adullact_mobile_path];
    
    
    NSArray *anchors = [[NSArray alloc] initWithObjects: (id)adullact_mobile, nil];
    
    SecTrustSetAnchorCertificatesOnly(trust, YES);
    SecTrustSetAnchorCertificates(trust, (CFArrayRef)anchors);
    
    NSURLCredential *newCredential = nil;
    
    SecTrustResultType res = kSecTrustResultInvalid;
    OSStatus sanityChesk = SecTrustEvaluate(trust, &res);
    
#ifdef DEBUG_SERVER_HTTPS
    for(long i = 0; i < SecTrustGetCertificateCount(trust); i++) {
        SecCertificateRef cr = SecTrustGetCertificateAtIndex(trust, i);
        
        
        CFStringRef summary = SecCertificateCopySubjectSummary(cr);
        
        NSLog(@"%@", summary);
    }
#endif
    
    if (sanityChesk == noErr &&
        (res == kSecTrustResultProceed || res == kSecTrustResultUnspecified) ) {
        
        newCredential = [NSURLCredential credentialForTrust:trust];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    }
    else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
#else
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
#endif
    
    
}


#pragma mark - Connection delegate for data downloading.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (_mimeType == nil) {
        _mimeType = [response MIMEType];
    }
    
    NSLog(@"%d", [(NSHTTPURLResponse*)response statusCode]);
    if ([(NSHTTPURLResponse*)response statusCode] != 200) {
        
        [connection cancel];
        [connection release];
        
        [self performSelectorOnMainThread:@selector(didEndWithUnReachableNetwork) withObject:nil waitUntilDone:YES];
        
        [_receivedData setLength:0];
    }
    else {
        
        NSString *req = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", req);
        [req release];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (downloadingDocument) {
        // trigger downloadedDoc delegate
        if ([_delegate respondsToSelector:@selector(didEndWithDocument:)]) {
            ADLDocument *document = [ADLDocument documentWithData:_receivedData AndMimeType:_mimeType];
            [_delegate performSelectorOnMainThread:@selector(didEndWithDocument:) withObject:document waitUntilDone:YES];
        }
    }
    else {
        // trigger api request delegate.
        
    }
}


@end
