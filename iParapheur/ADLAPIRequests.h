//
//  ADLAPIRequests.h
//  iParapheur
//
//  Created by Emmanuel Peralta on 02/01/13.
//
//

#import "ADLRequester.h"

#pragma mark - API Keys
/* Login / logout */
#define LOGIN_API               @"login"
#define LOGOUT_API              @"logout"

/* Data fetching */
#define GETBUREAUX_API          @"getBureaux"
#define GETDOSSIERSHEADERS_API  @"getDossiersHeaders"
#define GETDOSSIER_API          @"getDossier"
#define GETANNOTATIONS_API      @"getAnnotations"

/* editing api */
#define APPROVE_API             @"approve"

/* user details for display */
#define GETUSERDETAILS_API      @"getUserDetails"

#pragma mark - Commons

#define API_REQUEST(api, args) \
{ \
    ADLRequester *_requester = [ADLRequester sharedRequester]; \
    [_requester request:api andArgs:args delegate:self]; \
}

#pragma mark - login

#define API_LOGIN(username, password) \
{ \
    NSDictionary *_args = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil]; \
    API_REQUEST(LOGIN_API, _args); \
}

#define API_LOGIN_GET_TICKET(answer) \
    [[answer objectForKey:@"data"] objectForKey:@"ticket"]

#pragma mark - getBureaux

#define API_GETBUREAUX(username) \
{ \
    NSDictionary *_args = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", nil]; \
    API_REQUEST(GETBUREAUX_API, _args); \
}

#define API_GETBUREAUX_GET_BUREAUX(answer) \
    [answer objectForKey:@"bureaux"]

#pragma mark - getDossierHeaders

#define API_GETDOSSIERHEADERS(bureauCourant, page, pageSize) \
{ \
    NSDictionary *_args = [NSDictionary dictionaryWithObjectsAndKeys:bureauCourant, @"bureauCourant", \
                            page, @"page", \
                            pageSize, @"pageSize", nil]; \
    API_REQUEST(GETDOSSIERSHEADERS_API, _args); \
}

#define API_GETDOSSIERHEADERS_GET_DOSSIERS(answer) \
    [answer objectForKey:@"dossiers"]

#pragma mark - getDossier

#define API_GETDOSSIER(dossier, bureauCourant) \
{ \
    NSDictionary *_args = [NSDictionary dictionaryWithObjectsAndKeys:dossier, @"dossier", \
                            bureauCourant, @"bureauCourant", nil]; \
    API_REQUEST(GETDOSSIER_API, _args); \
}

#define API_GETANNOTATIONS(dossier, bureauCourant) \
{ \
    NSDictionary *_args = [NSDictionary dictionaryWithObjectsAndKeys:dossier, @"dossier", \
                            bureauCourant, @"bureauCourant", nil]; \
    API_REQUEST(GETANNOTATIONS_API, _args); \
}
