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
//  RGDetailViewController.m
//  iParapheur
//

#import "RGDetailViewController.h"
#import "ADLIParapheurWall.h"
#import "ADLCredentialVault.h"
#import "RGDeskCustomTableViewCell.h"

#import "LGViewHUD.h"

@interface RGDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation RGDetailViewController

@synthesize detailItem = _detailItem;
@synthesize deskArray = _deskArray; 

@synthesize masterPopoverController = _masterPopoverController;
/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}*/

- (void)dealloc
{
    [_detailItem release];
    [_masterPopoverController release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewPaperBackground.png"]]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    _deskArray = [[NSMutableArray alloc] init];
    
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if ([_deskArray count] == 0) {
    //    _deskArray = [[NSMutableArray alloc] init];
        
        
        ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
        [wall setDelegate:self];
        
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"eperalta", @"username", @"secret", @"password", nil];
        
        ADLCollectivityDef *def = [[ADLCollectivityDef alloc] init];
        
        [def setHost:V4_HOST];
        [def setUsername:@"eperalta"];
        
        [wall request:LOGIN_API withArgs:args andCollectivity:def];
        [def release];
    }
}

- (void)loadBureaux
{
    //FIXME: hardcored stuff

    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:@"eperalta", @"username", nil];
    
    ADLCollectivityDef *def = [[ADLCollectivityDef alloc] init];
    
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"";
    hud.bottomText=@"Chargement ...";
    hud.activityIndicatorOn=YES;
    [hud showInView:self.view];
    
    
    [def setHost:V4_HOST];
    [def setUsername:@"eperalta"];
    
    [wall request:GETBUREAUX_API withArgs:args andCollectivity:def];
    [def release];
}

- (void)viewDidUnload
{
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

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Wall impl

- (void)didEndWithRequestAnswer:(NSDictionary*)answer{
    NSString *s = [answer objectForKey:@"_req"];
    if ([s isEqual:LOGIN_API]) {
        
        ADLCredentialVault *vault = [ADLCredentialVault sharedCredentialVault];
        [vault addCredentialForHost:V4_HOST andLogin:@"eperalta" withTicket:[[answer objectForKey:@"data"] objectForKey:@"ticket"]];
        
        [self loadBureaux];
    }
    else if ([s isEqual:GETBUREAUX_API]) {
        NSArray *array = [[answer objectForKey:@"data"] objectForKey:@"bureaux"];

        [self setDeskArray:array];
          
        // add a cast to get rid of the warning since the view is indeed a table view it respons to reloadData
        [(UITableView*)([self view]) reloadData];
        
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationNone];
        
    }
    
    //storing ticket ? lacks the host and login information
    //we should add it into the request process ?
       
}

- (void)didEndWithUnReachableNetwork{
    
}

- (void)didEndWithUnAuthorizedAccess {
    
}

#pragma UITableDataSource delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_deskArray == nil) {
        return 0;
    }
    else {
        return [_deskArray count];
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DeskCell";
    
    RGDeskCustomTableViewCell *cell = (RGDeskCustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSDictionary *bureau = [ [self deskArray] objectAtIndex:[indexPath row]];
    NSLog(@"%@", [bureau objectForKey:@"name"]);
    [[cell textLabel] setText:[bureau objectForKey:@"name"]];
   
    NSNumber *a_traiter = [bureau objectForKey:@"a_traiter"];
    
    [[cell todoBadge] setBadgeText:[a_traiter stringValue]];
    [[cell todoBadge] autoBadgeSizeWithString: [a_traiter stringValue]];
    return cell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *bureau = [[self deskArray] objectAtIndex:[indexPath row]];
    NSLog(@"Selected Desk = %@", [bureau objectForKey:@"nodeRef"]);
    
    RGDeskViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"DeskViewController"];
    [controller setDeskRef:[bureau objectForKey:@"nodeRef"]];
    [[self navigationController] pushViewController:controller animated:YES];
}

@end
