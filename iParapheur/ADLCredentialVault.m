//
//  ADLCredentialVaults.m
//  MGSplitView
//
//

#import "ADLCredentialVault.h"


@implementation ADLCredentialVault

@synthesize vault;

#pragma mark -
#pragma mark Singleton Wizardry
#pragma mark -

static ADLCredentialVault *sharedCredentialVault = nil;

+ (ADLCredentialVault *)sharedCredentialVault {
    if (sharedCredentialVault == nil) {
        sharedCredentialVault = [[super allocWithZone:NULL] init];
    }
    return sharedCredentialVault;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedCredentialVault] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax; // denotes an object that cannot be released
}

- (void)release {
    // do nothing
}

- (id)autorelease {
    return self;
}

- (NSString*) buildKeyWithHost:(NSString*)host andLogin:(NSString*) login {
    return [NSString stringWithFormat:@"%@%@", host, login];
}

#pragma mark -
#pragma mark Methods for accessing alftickets
#pragma mark -

- (void) addCredentialForHost:(NSString*)host
                     andLogin:(NSString*)login
                   withTicket:(NSString*)ticket
{
    if (vault == nil) {
        vault = [[NSMutableDictionary alloc] init];
    }
    
    NSString *key = [self buildKeyWithHost:host andLogin:login];    
    [vault setObject:ticket forKey:key];
    
}

- (NSString*) getTicketForHost:(NSString*)host
                   andUsername:(NSString*)username
{
    NSString* key = [self buildKeyWithHost:host andLogin:username];
    
    return [vault objectForKey:key];
}

@end
