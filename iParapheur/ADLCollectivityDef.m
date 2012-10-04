//
//  ADLCollectivityDef.m
//  MGSplitView
//
//

#import "ADLCollectivityDef.h"

@implementation ADLCollectivityDef
@synthesize host;
@synthesize username;
+(ADLCollectivityDef*) copyDefaultCollectity {
    ADLCollectivityDef* defaultDef = [[ADLCollectivityDef alloc] init];
    
    NSString *url_preference = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"url_preference"];
    NSString *login_preference = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"login_preference"];
    
    [defaultDef setHost:url_preference];
    [defaultDef setUsername:login_preference];
    
    return defaultDef;
}

@end


