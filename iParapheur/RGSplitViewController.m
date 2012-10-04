/*
 * Version 1.1
 * CeCILL Copyright (c) 2012, SKROBS, ADULLACT-projet
 * Initiated by ADULLACT-projet S.A.
 * Developped by SKROBS
 *
 * contact@adullact-projet.coop
 *
 * Ce logiciel est un programme informatique servant à faire circuler des
 * documents au travers d'un circuit de validation, où chaque acteur vise
 * le dossier, jusqu'à l'étape finale de signature.
 *
 * Ce logiciel est régi par la licence CeCILL soumise au droit français et
 * respectant les principes de diffusion des logiciels libres. Vous pouvez
 * utiliser, modifier et/ou redistribuer ce programme sous les conditions
 * de la licence CeCILL telle que diffusée par le CEA, le CNRS et l'INRIA
 * sur le site "http://www.cecill.info".
 *
 * En contrepartie de l'accessibilité au code source et des droits de copie,
 * de modification et de redistribution accordés par cette licence, il n'est
 * offert aux utilisateurs qu'une garantie limitée.  Pour les mêmes raisons,
 * seule une responsabilité restreinte pèse sur l'auteur du programme,  le
 * titulaire des droits patrimoniaux et les concédants successifs.
 *
 * A cet égard  l'attention de l'utilisateur est attirée sur les risques
 * associés au chargement,  à l'utilisation,  à la modification et/ou au
 * développement et à la reproduction du logiciel par l'utilisateur étant
 * donné sa spécificité de logiciel libre, qui peut le rendre complexe à
 * manipuler et qui le réserve donc à des développeurs et des professionnels
 * avertis possédant  des  connaissances  informatiques approfondies.  Les
 * utilisateurs sont donc invités à charger  et  tester  l'adéquation  du
 * logiciel à leurs besoins dans des conditions permettant d'assurer la
 * sécurité de leurs systèmes et ou de leurs données et, plus généralement,
 * à l'utiliser et l'exploiter dans les mêmes conditions de sécurité.
 *
 * Le fait que vous puissiez accéder à cet en-tête signifie que vous avez
 * pris connaissance de la licence CeCILL, et que vous en avez accepté les
 * termes.
 */

//
//  RGSplitViewController.m
//  iParapheur
//

#import "RGSplitViewController.h"
#import "ADLCredentialVault.h"
#import "ADLIParapheurWall.h"

@implementation RGSplitViewController
@synthesize bureauView;

- (void)viewDidLoad {

   /* ADLIParapheurWall *wall = [[ADLIParapheurWall alloc] init];
    
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:@"eperalta",@"username",
                          @"secret", @"password", nil];
    
    ADLCollectivityDef *collDef = [[ADLCollectivityDef alloc] init];
    
    [collDef setHost:@"localhost:5150"];
    [collDef setUsername:@"eperalta"];
    [wall setDelegate:self];
    [wall request:LOGIN_API withArgs:args andCollectivity:collDef];*/
  /*[[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewPaperBackground.png"]]];*/
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark Wall Controller
#pragma mark -


- (void)didEndWithRequestAnswer:(NSDictionary*)answer{
    
    NSString *s = [answer objectForKey:@"_req"];
    if ([s isEqual:LOGIN_API]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Alert title when network error happens") message:[NSString stringWithFormat:@"%@", [[answer objectForKey:@"data"] objectForKey:@"ticket"]] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Alert view dismiss button") otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
        //storing ticket ? lacks the host and login information
        //we should add it into the request process ?
        [[ADLCredentialVault sharedCredentialVault] addCredentialForHost:V4_HOST
                                                                andLogin:@"eperalta" withTicket:[[answer    objectForKey:@"data"] objectForKey:@"ticket"]];
        
    }
    else if ([s isEqual:GETBUREAUX_API]) {
    //    [bureauView loadBureaux];
    }

    
}

- (void)didEndWithUnReachableNetwork{
    
}

- (void)didEndWithUnAuthorizedAccess {
    
}

@end
