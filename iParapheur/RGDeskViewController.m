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
//  RGDeskViewController.m
//  iParapheur
//

#import "RGDeskViewController.h"
#import "ADLIParapheurWall.h"
#import "RGMasterViewController.h"
#import "LGViewHUD.h"

@implementation RGDeskViewController

@synthesize deskRef;
@synthesize filesArray;
@synthesize detailViewController;
@synthesize loadMoreButton;
@synthesize searchBar;

#pragma mark - UIViewController delegate
-(void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TableViewPaperBackground.png"]]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    currentPage = 0;
    filesArray = [[NSMutableArray alloc] init];
    [self loadDossiersWithPage:currentPage];
    self.tableView.contentOffset = CGPointMake(0, self.searchBar.frame.size.height);
    
}

-(void)loadDossiersWithPage:(int)page {
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    //{"bureauRef":bureauRef, "page":page, "pageSize":pageSize}
    NSString *pageStr = @"0" ;//[NSString stringWithFormat:@"%d", page];
    
    NSDictionary *args = [[NSDictionary alloc]
                          initWithObjectsAndKeys:
                          deskRef, @"bureauRef",
                          [NSNumber numberWithInteger:page], @"page",
                          @"15", @"pageSize",
                          nil];
    
    [pageStr release];
    ADLCollectivityDef *collDef = [[ADLCollectivityDef alloc] init];
    
    [collDef setHost:V4_HOST];
    [collDef setUsername:@"eperalta"];
    
    [wall request:GETDOSSIERSHEADERS_API withArgs:args andCollectivity:collDef];
    [args release];
    [collDef release];
    
    
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"";
    hud.bottomText=@"Chargement ...";
    hud.activityIndicatorOn=YES;
    [hud showInView:self.view];
    
}

- (IBAction)loadNextResultsPage:(id)sender {
    [self loadDossiersWithPage:++currentPage]; 
}



#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [filesArray count];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DeskCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] init] autorelease];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSDictionary *dossier = [filesArray objectAtIndex:[indexPath row]];
    // NSLog(@"%@", [dossier objectForKey:@"titre"]);
    
    [[cell textLabel] setText:[dossier objectForKey:@"titre"]];
    
    
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *file = [[self filesArray] objectAtIndex:[indexPath row]];
    NSLog(@"Selected File = %@", [file objectForKey:@"dossierRef"]);
    /* [[self splitViewController] ]
     RGMasterViewController *controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"FileViewController"];*/
    
    NSString *dossierRef = [file objectForKey:@"dossierRef"];
    
    UINavigationController *nav = (UINavigationController*)[[[self splitViewController] viewControllers] lastObject];
    
    
    [[[nav viewControllers] objectAtIndex:0] setDossierRef:dossierRef];
    
    [[[[nav viewControllers] objectAtIndex:0] textView] setText:dossierRef];
    
    // [[self navigationController] pushViewController:controller animated:YES];
    /* wrooong */
}



#pragma mark - Wall delegate

-(void) didEndWithRequestAnswer:(NSDictionary *)answer {
    NSLog(@"Dossiers Headers Recieved ?");
    /*
    [self setFilesArray:[[answer objectForKey:@"data"] objectForKey:@"dossiers"]];*/
    
    if (currentPage > 0) {
        [filesArray removeLastObject];
    }
    else {
        [filesArray removeAllObjects];
    }
    [filesArray addObjectsFromArray:[[answer objectForKey:@"data"] objectForKey:@"dossiers"]];
    
    if ([[[answer objectForKey:@"data"] objectForKey:@"dossiers"] count] > 15) {
        [[self loadMoreButton ] setHidden:NO];
    }
    else {
        [[self loadMoreButton ] setHidden:YES];
    }
    
    [((UITableView*)[self view]) reloadData];
    
    [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationNone];
    
}

-(void) didEndWithUnAuthorizedAccess {
    
}

-(void) didEndWithUnReachableNetwork {
    
}

#pragma mark - Search Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    currentPage = 0;
    NSString *searchText = [searchBar text];
   
    ADLIParapheurWall *wall = [ADLIParapheurWall sharedWall];
    [wall setDelegate:self];
    //{"bureauRef":bureauRef, "page":page, "pageSize":pageSize}
    NSString *pageStr = @"0" ;//[NSString stringWithFormat:@"%d", page];
    NSDictionary *args = nil;
    if ([searchText isEqualToString:@""]) {
        // NSDictionary *filters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"*%@*",searchText], @"cm:name", nil];
        
        args = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                deskRef, @"bureauRef",
                //filters , @"filters",
                [NSNumber numberWithInteger:0], @"page",
                @"15", @"pageSize",
                nil];
        
    }
    else {
        NSDictionary *filters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"*%@*",searchText], @"cm:name", nil];
        
        args = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                deskRef, @"bureauRef",
                filters , @"filters",
                [NSNumber numberWithInteger:0], @"page",
                @"15", @"pageSize",
                nil];
    }
    
    
    [pageStr release];
    ADLCollectivityDef *collDef = [[ADLCollectivityDef alloc] init];
    
    [collDef setHost:V4_HOST];
    [collDef setUsername:@"eperalta"];
    
    [wall request:GETDOSSIERSHEADERS_API withArgs:args andCollectivity:collDef];
    [args release];
    [collDef release];
    
    
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"";
    hud.bottomText=@"Chargement ...";
    hud.activityIndicatorOn=YES;
    [hud showInView:self.view];
    [filesArray removeAllObjects];
    
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

}

- (void)dealloc {
    [loadMoreButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLoadMoreButton:nil];
    [super viewDidUnload];
}
@end
