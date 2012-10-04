//
//  ADLDocument.m
//  iParapheur
//
//

#import "ADLDocument.h"

@implementation ADLDocument
@synthesize documentData = _documentData;
@synthesize documentMimetype = _documentMimetype;

+(id) documentWithData:(NSData*)data AndMimeType:(NSString*)mimeType {
    
    id retVal = [[[ADLDocument alloc] init] autorelease];
    
    [retVal setDocumentData:data];
    [retVal setDocumentMimetype:mimeType];
    
    return retVal;
}

@end
