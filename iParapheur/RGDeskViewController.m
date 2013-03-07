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
//

#import "RGDeskViewController.h"
#import "RGMasterViewController.h"
#import "LGViewHUD.h"
#import "RGFileCell.h"
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import "ADLNotifications.h"
#import "ADLSingletonState.h"
#import "ADLRequester.h"

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
    
    _loading = NO;
    
    
    if (_refreshHeaderView == nil) {
        
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
        
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kDossierActionComplete object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kFilterChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeFilterPopover) name:kFilterPopoverShouldClose object:nil];
    
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
}

-(void)closeFilterPopover {
     [self popoverControllerDidDismissPopover:_filtersPopover];
}

-(void) refresh {
   
    [self loadDossiersWithPage:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
   // [[self navigationItem] setTitle:@"coucou"];
    currentPage = 0;
    filesArray = [[NSMutableArray alloc] init];
    [self loadDossiersWithPage:currentPage];
    self.tableView.contentOffset = CGPointMake(0, self.searchBar.frame.size.height);
}

-(void)loadDossiersWithPage:(int)page {
  /*
    ADLRequester *requester = [ADLRequester sharedRequester];
    [requester setDelegate:self];
    
  
    NSDictionary *args = [[NSDictionary alloc]
                          initWithObjectsAndKeys:
                          deskRef, @"bureauCourant",
                          [NSNumber numberWithInteger:page], @"page",
                          @"15", @"pageSize",
                          nil];
    

    
    [requester request:GETDOSSIERSHEADERS_API andArgs:args];
*/
    //
    NSDictionary *currentFilter = [[ADLSingletonState sharedSingletonState] currentFilter];
    if (currentFilter != nil) {
        API_GETDOSSIERHEADERS_FILTERED(deskRef, [NSNumber numberWithInteger:page], @"15", currentFilter);
    }
    else {
        API_GETDOSSIERHEADERS(deskRef, [NSNumber numberWithInteger:page], @"15");
    }
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
    static NSString *CellIdentifier = @"FileCell";
    
    RGFileCell *cell = (RGFileCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[[RGFileCell alloc] init] autorelease];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSDictionary *dossier = [filesArray objectAtIndex:[indexPath row]];
    // NSLog(@"%@", [dossier objectForKey:@"titre"]);
    
    [[cell filenameLabel] setText:[dossier objectForKey:@"titre"]];
    [[cell typeLabel] setText:[NSString stringWithFormat:@"%@ / %@", [dossier objectForKey:@"type"], [dossier objectForKey:@"sousType"]]];
    
    NSString *dateLimite = [dossier objectForKey:@"dateLimite"];
    if (dateLimite != nil) {
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        //[formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH:mm:ss'Z'"];
        NSDate *dueDate = [formatter dateFromString:dateLimite];
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"dd MMM"];
        
        NSString *fdate = [[outputFormatter stringFromDate:dueDate] retain];
        [[cell retardBadge] setBadgeText:fdate];
        [[cell retardBadge] autoBadgeSizeWithString: [NSString stringWithFormat:@" %@ ", fdate]];
        [[cell retardBadge] setHidden:NO];
        [fdate release];
        [formatter release];
        [outputFormatter release];

    }
    else {
        [[cell retardBadge] setHidden:YES];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *file = [[self filesArray] objectAtIndex:[indexPath row]];
    NSString *dossierRef = [file objectForKey:@"dossierRef"];
    [[ADLSingletonState sharedSingletonState] setDossierCourant:dossierRef];

    [[NSNotificationCenter defaultCenter] postNotificationName:kDossierSelected object:dossierRef];
}




#pragma mark - Wall delegate

-(void) didEndWithRequestAnswer:(NSDictionary *)answer {
    _loading = NO;
    
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    if (currentPage > 0) {
        [filesArray removeLastObject];
    }
    else {
        [filesArray removeAllObjects];
    }
    NSArray *dossiers = API_GETDOSSIERHEADERS_GET_DOSSIERS(answer);
    
    /* manualy filters the locked files out */
    if ([dossiers count] > 0) {
        NSMutableArray *lockedDossiers = [NSMutableArray arrayWithCapacity:[dossiers count]];
        for (NSDictionary *dossier in dossiers) {
            NSNumber *locked = [dossier objectForKey:@"locked"];
            if (locked && [locked isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                [lockedDossiers addObject:dossier];
            }
        }
        if ([lockedDossiers count] > 0) {
            dossiers = [NSMutableArray arrayWithArray:dossiers];
            [(NSMutableArray*)dossiers removeObjectsInArray:lockedDossiers];
        }
    }
                 
    [filesArray addObjectsFromArray:dossiers];
    
    if ([dossiers count] > 15) {
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
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBarClicked {
    currentPage = 0;
    NSString *searchText = [searchBarClicked text];
   
    ADLRequester *requester = [ADLRequester sharedRequester];
    
    NSString *pageStr = @"0";
    NSDictionary *args = nil;
   
    if ([searchText isEqualToString:@""]) {
        args = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                deskRef, @"bureauCourant",
                [NSNumber numberWithInteger:0], @"page",
                @"15", @"pageSize",
                nil];
        
    }
    else {
        NSMutableDictionary *filters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         [NSString stringWithFormat:@"*%@*",searchText], @"cm:name",nil];
        
        NSDictionary *currentFilter = [[ADLSingletonState sharedSingletonState] currentFilter];
        [filters addEntriesFromDictionary:currentFilter];
        
        args = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                deskRef, @"bureauCourant",
                filters , @"filters",
                [NSNumber numberWithInteger:0], @"page",
                @"15", @"pageSize",
                nil];
        
        [filters release];
    }
    
    
    [pageStr release];
    
    [requester request:GETDOSSIERSHEADERS_API andArgs:args delegate:self];
    //[args release];
    
    
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

#pragma mark - Pull to refresh delegeate implementation

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self refresh];
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _loading;
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
	return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (_filtersPopover != nil) {
        [_filtersPopover dismissPopoverAnimated:NO];
    }
    
    _filtersPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
    [_filtersPopover setDelegate:self];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (_filtersPopover != nil && popoverController == _filtersPopover) {
        [_filtersPopover dismissPopoverAnimated:YES];
        _filtersPopover = nil;
    }
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
