//
//  ADLIParapheurController.m
//  MGSplitView
//

//

#import "ADLIParapheurWall.h"
#import "ADLMacroes.h"


#import "ADLCredentialVault.h"

@implementation ADLIParapheurWall 
@synthesize currentRequest;
@synthesize delegate;

static ADLIParapheurWall *sharedWall = nil;

+ (ADLIParapheurWall *)sharedWall {
    if (sharedWall == nil) {
        sharedWall = [[super allocWithZone:NULL] init];
    }
    return sharedWall;
}


-(id) init {
    serialQueue = dispatch_queue_create("org.adullact.iParapheur.serial", DISPATCH_QUEUE_SERIAL);
    dispatch_retain(serialQueue);
    
    return self;
}

- (void) request:(NSString*) req
        withArgs:(NSDictionary*)args
 andCollectivity:(ADLCollectivityDef *)def {
    
   // dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_async(aQueue, ^{
        
            [self _request:req withArgs:args andCollectivity:def];

    //});
}




- (void) _request:(NSString*) req
        withArgs:(NSDictionary*)args
 andCollectivity:(ADLCollectivityDef *)def
{
    
    dispatch_queue_t current = dispatch_get_current_queue();
    
    NSLog(@"running request on %s", dispatch_queue_get_label(current));
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability currentReachabilityStatus] == NotReachable) {
        if (delegate)
            [delegate didEndWithUnReachableNetwork];
    }
    else {
        ADLCredentialVault *vault = [ADLCredentialVault sharedCredentialVault];
        NSString *alf_ticket = [vault getTicketForHost:[def host] andUsername:[def username]];
        NSURL *requestURL = nil;
        
        currentRequest = req;
        
        if (alf_ticket != nil) {
            
//TODO: check the ticket if its wrong ask for another one
            requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/alfresco/service/parapheur/api/%@?alf_ticket=%@", [def host], req, alf_ticket]]; 
        }
        else {
            requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/alfresco/service/parapheur/api/%@", [def host], req]];
        }
        NSLog(@"%@", [NSString stringWithFormat:@"http://%@/alfresco/service/parapheur/api/%@", [def host], req]);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
        [requestURL release];
        
        // [request setCachePolicy:NSURLCacheStorageAllowed];
        
        NSDictionary *requestArgs = [NSDictionary dictionaryWithDictionary:args];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        
        isDownloadingDocument = NO;
        
        NSLog(@"%@", [requestArgs JSONString]);
        [request setHTTPBody:[requestArgs JSONData]];
        
        //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        //[connection start];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue: [NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error == nil) {
                                       
                                       NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       //dispatch_sync(serialQueue, ^{
                                           
                                           [self parseResponse:str andReq:req];
                                           [str release];
                                      // });
                                   }
                                   else {
                                       [self didEndWithError:error];
                                   }
                                   
                                   
                               }];
        
        /*[connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
        */
        //receivedData=[[NSMutableData data] retain];
        
        [request release]; 
    }
}

- (void) didEndWithError:(NSError*) error {
    
    NSLog(@"%@", [error localizedDescription]);
    NSLog(@"%@", [error localizedFailureReason]);
    
}


- (void) downloadDocumentWithNodeRef:(NSString*)nodeRef  andCollectivity:(ADLCollectivityDef *)def {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability currentReachabilityStatus] == NotReachable) {
        if (delegate)
            [delegate didEndWithUnReachableNetwork];
    }
    else {
        
        ADLCredentialVault *vault = [ADLCredentialVault sharedCredentialVault];
        NSString *alf_ticket = [vault getTicketForHost:[def host] andUsername:[def username]];
        NSURL *requestURL = nil;
        
        //NSString *nodeRefPath = [nodeRef stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
        
        if (alf_ticket != nil) {
            requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/alfresco/service%@?alf_ticket=%@", [def host], nodeRef, alf_ticket]]; 
        }
        else {
            NSLog(@"Error while DL/ing the document");
        }
        
        NSLog(@"%@", [NSString stringWithFormat:@"http://%@/alfresco/service%@?alf_ticket=%@", [def host], nodeRef, alf_ticket]);
     /*   
        NSLog(@"%@", [NSString stringWithFormat:@"http://%@/parapheur/api/%@", [def host], req]);
      */
        
       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
        [requestURL release];
        
        [request setHTTPMethod:@"GET"];
        
        isDownloadingDocument = YES;
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
        
        receivedData= [[NSMutableData data] retain];
        
        [request release]; 
        
    }
}

- (void) loginWithUserName:(NSString*)username
                  password:(NSString*)password

{
    
    return;
}

#pragma mark -
#pragma mark Https selfsigned certificates delegate



- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        // NSLog(@"%", challenge.protectionSpace.host);
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
#pragma mark -
#pragma mark Others Connection delegates


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    
    if (mimeType == nil) {
        mimeType = [response MIMEType];
    }
    
    NSLog(@"%d", [(NSHTTPURLResponse*)response statusCode]);
    if ([(NSHTTPURLResponse*)response statusCode] != 200) {
        
        [connection cancel];
        [connection release];
        //if (delegate)
        [self performSelectorOnMainThread:@selector(didEndWithUnReachableNetwork) withObject:nil waitUntilDone:YES];
        //}
        
        [receivedData setLength:0];
    }
    else {
        
        NSString *req = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", req);
        [req release];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    if (delegate)
        [self performSelectorOnMainThread:@selector(didEndWithUnReachableNetwork) withObject:nil waitUntilDone:YES];

    // inform the user
    NSLog(@"Connection failed! Error - %@",
          [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];
    
    if (isDownloadingDocument == NO) {
        NSString *str = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
        [receivedData release];
        [self parseResponse:str];
        //[self performSelectorInBackground:@selector(parseResponse:) withObject:str];
        [str release];
    }
    else {
        // we are DL/ing a document so we store NSData SomeWhere
        
        if (delegate) {
            if ([delegate respondsToSelector:@selector(didEndWithDocument:)]) {
                document = [ADLDocument documentWithData:receivedData AndMimeType:mimeType];
                [delegate performSelectorOnMainThread:@selector(didEndWithDocument:) withObject:document waitUntilDone:YES];
            }
        }
    }
}

-(void) parseResponse:(NSString*) response andReq:(NSString*)req {
    NSDictionary* responseObject = [response objectFromJSONString];
    NSMutableDictionary* retVal = [NSMutableDictionary dictionaryWithDictionary:responseObject];
    
    [retVal setObject:req forKey:@"_req"];

    if (delegate != nil) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        
        //dispatch_async(mainQueue, ^{
            [delegate didEndWithRequestAnswer:retVal];
        //});
        
        //[delegate performSelectorOnMainThread:@selector(didEndWithRequestAnswer:) withObject:retVal waitUntilDone:YES];
    }
    else {
        [self didEndWithRequestAnswer: responseObject];    
    } 
}

#pragma mark -
#pragma mark Parapheur Wall Api delegates


- (void)didEndWithRequestAnswer:(NSDictionary*)answer {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Alert title when network error happens") message:[NSString stringWithFormat:@"%@", [[answer objectForKey:@"data"] objectForKey:@"ticket"]] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Alert view dismiss button") otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    /*
     if ([[answer request] isEqual:@"auth"]) {
     if ([answer boolValue] == YES) {
     [self request:[authRequestArgs valueForKey:@"action"] withArgs:authRequestArgs];
     }
     else {
     [self didEndWithUnAuthorizedAccess];
     //NSLog(@"Auth Failed Dropping Request");
     }
     }*/
}

- (void) didEndWithUnReachableNetwork {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Alert title when network error happens") message:NSLocalizedString(@"Unable to reach host, please check your network settings.", @"Text displayed in the UIAlertView when the application can't reach the server") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Alert view dismiss button") otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)didEndWithUnAuthorizedAccess {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"AlertView Title on Error") message:NSLocalizedString(@"You have been disconnected", @"Error Message that appears when the user session has timed out") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Alert view dismiss button") otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    //[(AppDelegate*)[[UIApplication sharedApplication] delegate] displayUnAuthTabBar:YES selected:2];
    
    //[[NHAccountInfo sharedAccountInfo] setAccountID:nil];
    //[[NHAccountInfo sharedAccountInfo] setSessionKey:nil];
    
    //[delegate performSelector:@selector(didEndWithUnAuthorizedAccess)];
}





@end
