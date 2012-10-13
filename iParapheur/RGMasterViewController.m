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
//  RGMasterViewController.m
//  iParapheur
//
//

#import "RGMasterViewController.h"
#import "RGWorkflowDialogViewController.h"
#import "RGDetailViewController.h"
#import "RGReaderViewController.h"
#import "RGAppDelegate.h"
#import "RGDocumentsView.h"

#import "ADLIParapheurWall.h"
#import "ADLCredentialVault.h"
#import "ADLCollectivityDef.h"
#import "ADLCircuitCell.h"
#import "ISO8601DateFormatter.h"

#import "LGViewHUD.h"

@interface RGMasterViewController () {
    NSMutableArray *_objects;
    __weak UIPopoverController *documentsPopover;
}
@end

@implementation RGMasterViewController
@synthesize documentsButtonItem;
@synthesize viserButton;
@synthesize detailViewController = _detailViewController;
@synthesize dossierName;
@synthesize textView;
@synthesize dossierRef;
@synthesize typeLabel;
@synthesize sousTypeLabel;
@synthesize dossierNameLabel;
@synthesize circuitTable;
@synthesize sousTypeValueLabel;
@synthesize typeValueLabel;
@synthesize rejectButton;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
       /* self.clearsSelectionOnViewWillAppear = NO;*/
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    documents = [[NSArray alloc] init];
    [super awakeFromNib];
}

- (void)dealloc
{
    [_detailViewController release];
    [_objects release];
    [circuitTable release];
    [viserButton release];
    [rejectButton release];
    [dossierNameLabel release];
    [sousTypeValueLabel release];
    [typeValueLabel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   /*
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (RGDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    */
    self.navigationItem.rightBarButtonItem=nil;
    [textView setText:dossierRef];
    _objects = [[[NSMutableArray alloc] init] retain];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewPaperBackground.png"]]];
    
    [self hidesEveryThing];
    [[self dossierName] setText:[_dossier objectForKey:@"titre"]];
    [[self typeLabel] setText:[_dossier objectForKey:@"type"]];
    [[self sousTypeLabel] setText:[_dossier objectForKey:@"sousType"]];
    dossierRef = [_dossier objectForKey:@"dossierRef"];
    documents = [[_dossier objectForKey:@"documents"] retain];
    self.navigationItem.rightBarButtonItem = documentsButtonItem;
    [self getCircuit];
    [self showsEveryThing];
    
    
}

- (void)viewDidUnload
{
    [self setCircuitTable:nil];
    [self setViserButton:nil];
    [self setRejectButton:nil];
    [self setDossierNameLabel:nil];
    [self setSousTypeValueLabel:nil];
    [self setTypeValueLabel:nil];
    
    //unregister observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) dossierSelected:(NSNotification*)notification {
    NSString *selectedDossierRef  = [notification object];
   
    [self setDossierRef:selectedDossierRef];
}

- (void) setDossierRef:(NSString *)_dossierRef {
    dossierRef = [_dossierRef retain];
    
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:_dossierRef,
                          @"dossierRef", nil];
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    
    [wall request:GETDOSSIER_API withArgs:args andCollectivity:def];
    [def release];
    
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"";
    hud.bottomText=@"Chargement ...";
    hud.activityIndicatorOn=YES;
    [hud showInView:self.view];

}
/*
- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}*/

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CircuitCell";
    ADLCircuitCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[ADLCircuitCell alloc] init] autorelease];
    }
    
    NSDictionary *object = [_objects objectAtIndex:indexPath.row];
   // cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [object objectForKey:@"parapheurName"], [object objectForKey:@"actionDemandee"]];
    
    [[cell parapheurName] setText:[object objectForKey:@"parapheurName"]];
    if ([[object objectForKey:@"approved"] intValue] == 1) {
    [[cell validateurName] setText:[object objectForKey:@"signataire"]];
    }
    else {
        [[cell validateurName] setText:nil];
    }
    
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    
    NSString *validationDateIso = [object objectForKey:@"dateValidation"];
    if (validationDateIso != nil && ![validationDateIso isEqualToString:@""]) {
        NSDate * validationDate = [formatter dateFromString:validationDateIso];
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"'le' dd/MM/yyyy 'à' HH:mm"];
        
        NSString *validationDateStr = [[outputFormatter stringFromDate:validationDate] retain];
        
        [[cell validationDate] setText:validationDateStr];
    
    }
    else {
        [[cell validationDate] setText:nil];
    }
    
    NSString *imagePrefix = @"iw";
    if ([[object objectForKey:@"approved"] intValue] == 1) {
        imagePrefix = @"ip";
    }
    
    NSString *action = [[object objectForKey:@"actionDemandee"] lowercaseString];
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@-%@.jpg", imagePrefix, action ]);
    
    [[cell etapeTypeIcon] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-%@.jpg", imagePrefix, action ]]];
    
    /*
    if ([[object objectForKey:@"approved"] isEqual:[NSNumber numberWithInt:1]]) {
        [cell.textLabel setTextColor:[UIColor greenColor]];
    }*/
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
- (IBAction)showDocumentsViewController:(id)sender {
    if (documentsPopover) 
        [documentsPopover dismissPopoverAnimated:YES];
    else
        [self performSegueWithIdentifier:@"showDocumentsView" sender:sender];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = [_objects objectAtIndex:indexPath.row];
        self.detailViewController.detailItem = object;
    }
}
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = [_objects objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}*/

- (void) getCircuit {
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:dossierRef,
                          @"dossierRef", nil];
    
    ADLCollectivityDef *def = [ADLCollectivityDef copyDefaultCollectity];
    
    [wall request:@"getCircuit" withArgs:args andCollectivity:def];
    [def release];
    
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"";
    hud.bottomText=@"Chargement ...";
    hud.activityIndicatorOn=YES;
    [hud showInView:self.view];
}
#pragma mark - Wall impl

- (void)didEndWithRequestAnswer:(NSDictionary*)answer{
    NSString *s = [answer objectForKey:@"_req"];
    if ([s isEqual:GETDOSSIER_API]) {
        //[deskArray removeAllObjects];
        @synchronized(self)
        {
                        
            [textView setText:[answer JSONString]];
            
            //[self refreshViewWithDossier:[answer objectForKey:@"data"]];
        }
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationNone];
        [self getCircuit];
        [self showsEveryThing];
    }
    else if ([s isEqualToString:@"getCircuit"]) {
        @synchronized(self)
        {
            [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationNone];
            /*if (_objects == nil) {
             _objects = [[[NSMutableArray alloc] init] retain];
             }*/
            [_objects removeAllObjects];
            [_objects addObjectsFromArray:[[answer objectForKey:@"data"] objectForKey:@"circuit"]];
            [circuitTable reloadData];

            
            /* Basic handling of actions. */
            NSString *currentAction = nil;
            for (NSDictionary* etape in _objects) {
                if (![[etape objectForKey:@"approved"] isEqual:[NSNumber numberWithInt:1]]) {
                    currentAction = [etape objectForKey:@"actionDemandee"];
                    break;
                }
            }
            
            if ([currentAction isEqualToString:@"VISA"]) {
                [[self viserButton] setHidden:NO];
            }
            else {
                [[self viserButton] setHidden:YES];
            }
        }
    }    
}
- (void)didEndWithUnReachableNetwork{
    
}

- (void)didEndWithUnAuthorizedAccess {
    
}

#pragma mark - View Refresh with data


- (void) refreshCircuit:(NSDictionary*)circuit {
    
}

#pragma mark - IBActions


- (IBAction)showVisuelPDF:(id)sender {
    NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
	NSString *filePath = [pdfs lastObject];
    
    ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:filePath password:nil];
    
    readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    [readerViewController setDelegate:self];
    
    readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;

    [[self splitViewController] presentModalViewController:readerViewController animated:YES];
    [document release];
    [readerViewController release];
    
}

- (void) dismissReaderViewController:(ReaderViewController *)viewController {
    // do nothing for now
    [[self splitViewController] dismissModalViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    if ([[segue identifier] isEqualToString:@"showDocumentsView"]) {
        
        if (documentsPopover) {
            [documentsPopover dismissPopoverAnimated:NO];
            [documentsPopover release];
            documentsPopover = nil;
        } 
        documentsPopover = [[(UIStoryboardPopoverSegue *)segue popoverController] retain];
        
        [((RGDocumentsView
           *)[segue destinationViewController]) setDocuments:documents];
        
        [((RGDocumentsView
           *)[segue destinationViewController]) setSplitViewController:[self splitViewController]];
        
        [((RGDocumentsView
           *)[segue destinationViewController]) setPopoverController:[(UIStoryboardPopoverSegue *)segue popoverController]];
    }*/
    
    if ([[segue identifier] isEqualToString:@"viser"]) {
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setDossierRef:[self dossierRef]];
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setAction:[segue identifier]];
    }
    
    if ([[segue identifier] isEqualToString:@"reject"]) {
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setDossierRef:[self dossierRef]];
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setAction:[segue identifier]];
    }
}

-(void) presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    [super presentModalViewController:modalViewController animated:animated];
}


-(void) hidesEveryThing {
    [self setHiddenForEveryone:YES];

}

-(void)showsEveryThing {
    [self setHiddenForEveryone:NO];
}

-(void)setHiddenForEveryone:(BOOL)val {
    [dossierName setHidden:val];
    [typeLabel setHidden:val];
    [sousTypeLabel setHidden:val];
    [circuitTable setHidden:val];
    [dossierNameLabel setHidden:val];
    [rejectButton setHidden:val];
    [typeValueLabel setHidden:val];
    [sousTypeValueLabel setHidden:val];
}




@end
