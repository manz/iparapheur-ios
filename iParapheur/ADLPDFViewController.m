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
//  ADLPDFViewController.m
//  iParapheur
//


#import "ADLPDFViewController.h"
#import "ReaderContentView.h"
#import "ADLIParapheurWall.h"
#import "LGViewHUD.h"
#import "RGMasterViewController.h"
#import "RGDocumentsView.h"
#import "ADLNotifications.h"
#import "ADLSingletonState.h"
#import "ADLRequester.h"


@interface ADLPDFViewController ()

@end

@implementation ADLPDFViewController
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
@synthesize container;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dossierSelected:) name:kDossierSelected object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectBureauAppeared:)
                                                 name:kSelectBureauAppeared object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDocumentWithIndex:) name:kshowDocumentWithIndex object:nil];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - selector for observer

- (void) dossierSelected: (NSNotification*) notification {
    NSString *dossierRef = [notification object];
    
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    
    _dossierRef = dossierRef;
    
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:dossierRef,
                          @"dossier",
                          [[ADLSingletonState sharedSingletonState] bureauCourant], @"bureauCourant",
                          nil];
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    
    [wall request:GETDOSSIER_API withArgs:args andCollectivity:def];
    
    [wall request:GETANNOTATIONS_API withArgs:args andCollectivity:def];
    
    
    [def release];
    //[args release];
    
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"";
    hud.bottomText=@"Chargement ...";
    hud.activityIndicatorOn=YES;
    
    [hud showInView:self.view];
    /*
    UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(test)];
    */
     
    NSArray *buttons = [[NSArray alloc] initWithObjects:_actionButton, _detailsButton, nil];
    
    self.navigationItem.leftBarButtonItem = _documentsButton;
    self.navigationItem.rightBarButtonItems = buttons;
    
    [[self navigationController] popToRootViewControllerAnimated:YES];

    [buttons release];
}

-(void) selectBureauAppeared:(NSNotification*) notification {
    for(UIView *subview in [self.view subviews]) {
        [subview removeFromSuperview];
    }
    
    [[self navigationController] popToRootViewControllerAnimated:YES];

    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
   // [[self readerViewController] release];
    _readerViewController = nil;
}

-(void) showDocumentWithIndex:(NSNotification*) notification {
    NSNumber* docIndex = [notification object];
    [self displayDocumentAt:[docIndex integerValue]];
    [_documentsPopover dismissPopoverAnimated:YES];
    _documentsPopover = nil;
    
}


#pragma mark - Wall delegate Implementation
-(void) displayDocumentAt: (NSInteger) index {
    NSDictionary *document = [[_dossier objectForKey:@"documents" ] objectAtIndex:index];
    
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"";
    hud.bottomText=@"Chargement ...";
    hud.activityIndicatorOn=YES;
    
    [hud showInView:self.view];
    
    ADLRequester *requester = [ADLRequester sharedRequester];
    
    requester.delegate = self;
    
    
    /* Si le document n'a pas de visuelPdf on suppose que le document est en PDF */
    if ([document objectForKey:@"visuelPdfUrl"] != nil) {
        [requester downloadDocumentAt:[document objectForKey:@"visuelPdfUrl"]];

        //[wall downloadDocumentWithNodeRef:[document objectForKey:@"visuelPdfUrl"] andCollectivity:def];
    }
    else if ([document objectForKey:@"downloadUrl"] != nil) {
        [requester downloadDocumentAt:[document objectForKey:@"downloadUrl"]];
        //[wall downloadDocumentWithNodeRef:[document objectForKey:@"downloadUrl"] andCollectivity:def];
    }
    [def release];
}

-(void)didEndWithRequestAnswer:(NSDictionary*)answer {
    NSString *s = [answer objectForKey:@"_req"];
    [[LGViewHUD defaultHUD] setHidden:YES];
    NSLog(@"%@", answer);
    if ([s isEqual:GETDOSSIER_API]) {
        _dossier = [answer copy];
        [self displayDocumentAt: 0];
        
        LGViewHUD *hud = [LGViewHUD defaultHUD];
        hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
        hud.topText=@"";
        hud.bottomText=@"Chargement ...";
        hud.activityIndicatorOn=YES;
        
        [hud showInView:self.view];
    
    }
    else if ([s isEqualToString:GETANNOTATIONS_API]) {
        NSArray *annotations = [[answer objectForKey:@"annotations"] copy];
        
        NSLog(@"annotations %@", annotations);
        
        _annotations = annotations;
        
        for (NSNumber *contentViewIdx in [_readerViewController contentViews]) {
            [[[[_readerViewController contentViews] objectForKey:contentViewIdx] contentPage] refreshAnnotations];
        }

    }
    else if ([s isEqualToString:@"addAnnotation"]) {
        ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
        [wall setDelegate:self];
        
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              _dossierRef,
                              @"dossier",
                              nil];
        
        ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
        
        [wall request:GETANNOTATIONS_API withArgs:args andCollectivity:def];
    }
    
}

- (void)didEndWithUnReachableNetwork {
    
}

- (void)didEndWithUnAuthorizedAccess {
    
}


- (void)didEndWithDocument:(ADLDocument*)document {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSFileHandle *file;
    
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString *docPath = [documentsPaths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, @"myfile.bin"];
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    
    file = [NSFileHandle fileHandleForWritingAtPath: filePath];
    [file writeData:[document documentData]];
    
    
    ReaderDocument *readerDocument = [[ReaderDocument alloc] initWithFilePath:filePath password:nil];
    
    _readerViewController = [[ReaderViewController alloc] initWithReaderDocument:readerDocument];
    
    [_readerViewController setDataSource:self];
    
    [readerDocument release];
    
    _readerViewController.delegate = self;
    _readerViewController.view.frame = [[self view] frame];
    
    [_readerViewController.view setAutoresizingMask:( UIViewAutoresizingFlexibleWidth |
                                                 UIViewAutoresizingFlexibleHeight )];
    [[self view] setAutoresizesSubviews:YES];
    
    for(UIView *subview in [self.view subviews]) {
        [subview removeFromSuperview];
    }

    [[self view] addSubview:[_readerViewController view]];
     
    [[LGViewHUD defaultHUD] setHidden:YES];
    
    
    
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
            
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                          _dossierRef,
                          @"dossier",
                          nil];
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    
    [wall request:GETANNOTATIONS_API withArgs:args andCollectivity:def];
    
    
    [def release];
    //[args release];
    
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"";
    hud.bottomText=@"Chargement ...";
    hud.activityIndicatorOn=YES;
    
    [hud showInView:self.view];
    
  //  self.navigationItem.leftBarButtonItem = _documentsButton;
  //  self.navigationItem.rightBarButtonItem = _detailsButton;
    
  //  [[self navigationController] popToRootViewControllerAnimated:YES];

}


- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
    
	[self.navigationController popViewControllerAnimated:YES];
    
#else // dismiss the modal view controller
    
	[self dismissModalViewControllerAnimated:YES];
    
#endif // DEMO_VIEW_CONTROLLER_PUSH
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
   
 
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [_readerViewController updateScrollViewContentViews];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"dossierDetails"]) {
        [((RGMasterViewController*) [segue destinationViewController]) setDossier:_dossier];
    }
    
    if ([[segue identifier] isEqualToString:@"showDocumentPopover"]) {
        [((RGDocumentsView*)[segue destinationViewController]) setDocuments:[_dossier objectForKey:@"documents"]];
        if (_documentsPopover != nil) {
            [_documentsPopover dismissPopoverAnimated:NO];
        }
        
        _documentsPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        [_documentsPopover setDelegate:self];

    }
    
    if ([[segue identifier] isEqualToString:@"showActionPopover"]) {
        if (_actionPopover != nil) {
            [_actionPopover dismissPopoverAnimated:NO];
        }
        
        _actionPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        [_actionPopover setDelegate:self];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    if (_documentsPopover != nil && _documentsPopover == popoverController) {
        _documentsPopover = nil;
    }
    else if (_actionPopover != nil && _actionPopover == popoverController) {
        _actionPopover = nil;
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [container release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setContainer:nil];
    [super viewDidUnload];
}

#pragma mark - Annotations Drawing view data Source

-(NSArray*) annotationsForPage:(NSInteger)page {
    NSMutableArray *annotsAtPage = [[[NSMutableArray alloc] init] autorelease];
    for (NSDictionary *etape in _annotations) {
        NSArray *annotationsAtPageForEtape = [etape objectForKey:[NSString stringWithFormat:@"%d", page]];
        
/*        for (NSNumber *key in etape) {
            NSLog(@"%@", [etape objectForKey:key]);
        }
  */      
        if (annotationsAtPageForEtape != nil && [annotationsAtPageForEtape count] > 0) {
            [annotsAtPage addObjectsFromArray:annotationsAtPageForEtape];
        }
    }
    
    return annotsAtPage;
}


-(void) updateAnnotation:(ADLAnnotation*)annotation forPage:(NSUInteger)page {
    NSDictionary *dict = [annotation dict];
    NSDictionary *req = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithUnsignedInteger:page], @"page",
                         dict, @"annotation",
                         [[ADLSingletonState sharedSingletonState] dossierCourant], @"dossier"
                         , nil];
    
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];

    [wall request:@"updateAnnotation" withArgs:req andCollectivity:def]; 
    
}

-(void) removeAnnotation:(ADLAnnotation*)annotation {
       NSDictionary *req = [NSDictionary dictionaryWithObjectsAndKeys:
                         [annotation uuid], @"uuid",
                            [NSNumber numberWithUnsignedInt:10], @"page",
                         [[ADLSingletonState sharedSingletonState] dossierCourant], @"dossier"
                         , nil];
    
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    
    [wall request:@"removeAnnotation" withArgs:req andCollectivity:def];
}

-(void) addAnnotation:(ADLAnnotation*)annotation forPage:(NSUInteger)page {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[annotation dict]];
    [dict setValue: [NSNumber numberWithUnsignedInteger:page] forKey:@"page"];
    NSDictionary *req = [NSDictionary dictionaryWithObjectsAndKeys:
                        
                         [NSArray arrayWithObjects:dict, nil], @"annotations",
                         [[ADLSingletonState sharedSingletonState] dossierCourant], @"dossier"
                         , nil];
    
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    
    [wall request:@"addAnnotation" withArgs:req andCollectivity:def];

    
}

@end
