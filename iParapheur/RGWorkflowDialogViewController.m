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
//  RGWorkflowDialogViewController.m
//  iParapheur
//
//

#import "RGWorkflowDialogViewController.h"
#import "ADLIParapheurWall.h"
#import "ADLCollectivityDef.h"
#import "ADLNotifications.h"
#import "ADLSingletonState.h"

@interface RGWorkflowDialogViewController ()

@end

@implementation RGWorkflowDialogViewController
@synthesize annotationPrivee;
@synthesize annotationPublique;
@synthesize finishButton;
@synthesize action;
@synthesize dossierRef;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void)viewDidUnload
{
    [self setAnnotationPrivee:nil];
    [self setAnnotationPublique:nil];
    [self setFinishButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([action isEqualToString:@"viser"]) {
        [finishButton setTitle:@"Viser" forState:UIControlStateNormal];
    }
    else if ([action isEqualToString:@"reject"]) {
        [finishButton setTitle:@"Rejeter" forState:UIControlStateNormal];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)finish:(id)sender {
    
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];

    NSDictionary *args = [[NSDictionary alloc]
                          initWithObjectsAndKeys:
                          [NSArray arrayWithObjects:dossierRef, nil], @"dossiers",
                          [annotationPublique text], @"annotPub",
                          [annotationPrivee text], @"annotPriv",
                          [[ADLSingletonState sharedSingletonState] bureauCourant], @"bureauCourant",
                          nil];
    
    ADLCollectivityDef *collDef = [ADLCollectivityDef copyDefaultCollectity];
    

    if ([action isEqualToString:@"viser"]) {
        [wall request:@"visa" withArgs:args andCollectivity:collDef];
    }
    else if ([action isEqualToString:@"reject"]) {
        [wall request:@"reject" withArgs:args andCollectivity:collDef];
    }
    [args release];
    [collDef release];
    
    /*
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"";
    hud.bottomText=@"Chargement ...";
    hud.activityIndicatorOn=YES;
    [hud showInView:self.view];*/
    
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [annotationPrivee release];
    [annotationPublique release];
    [finishButton release];
    [super dealloc];
}

-(void) didEndWithRequestAnswer:(NSDictionary *)answer {
    
    [self dismissModalViewControllerAnimated:YES];

}

-(void) didEndWithUnAuthorizedAccess {
    
}

-(void) didEndWithUnReachableNetwork {
    
}

@end
