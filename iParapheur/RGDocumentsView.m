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
//  RGDocumentsView.m
//  iParapheur
//


#import "RGDocumentsView.h"
#import "ADLDocument.h"
#import "ADLIParapheurWall.h"
#import "ReaderDocument.h"
#import "ReaderViewController.h"

@interface RGDocumentsView ()

@end

@implementation RGDocumentsView
@synthesize splitViewController = _splitViewController;
@synthesize documents = _documents;
@synthesize popoverController = __popoverController;

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_documents count];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DocumentCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] init] autorelease];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSDictionary *document = [_documents objectAtIndex:[indexPath row]];
    // NSLog(@"%@", [dossier objectForKey:@"titre"]);
    
    [[cell textLabel] setText:[document objectForKey:@"name"]];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *document = [_documents objectAtIndex:[indexPath row]];
    
    
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    
    
    ADLCollectivityDef *def = [[ADLCollectivityDef alloc] init];
    
    [def setHost:V4_HOST];
    [def setUsername:@"eperalta"];
    if ([[document objectForKey:@"visuelPdfUrl"] isEqual:@""]) {
    [wall downloadDocumentWithNodeRef:[document objectForKey:@"downloadUrl"] andCollectivity:def];
    }
else {
   [wall downloadDocumentWithNodeRef:[document objectForKey:@"visuelPdfUrl"] andCollectivity:def]; 
}
}

#pragma mark - Wall delegate
- (void)didEndWithRequestAnswer:(NSDictionary*)answer{
}

- (void)didEndWithUnReachableNetwork{
}

- (void)didEndWithUnAuthorizedAccess {
}

- (void)didEndWithDocument:(ADLDocument*) document {
   // [[self popoverController] dismissPopoverAnimated:YES];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSFileHandle *file;
    
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString *docPath = [documentsPaths objectAtIndex:0]; // stringByDeletingLastPathComponent];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, @"myfile.bin"];
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    
    file = [NSFileHandle fileHandleForWritingAtPath: filePath];
    [file writeData:[document documentData]];
    
    
    ReaderDocument *readerDocument = [[ReaderDocument alloc] initWithFilePath:filePath password:nil];
    
    ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:readerDocument];
    [readerViewController setDelegate:self];
    
    readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [__popoverController dismissPopoverAnimated:NO];
    
    //- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion

    [_splitViewController presentModalViewController:readerViewController animated:YES];
    [readerDocument release];
    [readerViewController release];

}

- (void) dismissReaderViewController:(ReaderViewController *)viewController {
    // do nothing for now
    [_splitViewController dismissModalViewControllerAnimated:YES];
    
}


@end
