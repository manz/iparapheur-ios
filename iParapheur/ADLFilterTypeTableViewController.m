//
//  ADLFilterTypeTableViewController.m
//  iParapheur
//
//  Created by Emmanuel Peralta on 21/02/13.
//
//

#import "ADLFilterTypeTableViewController.h"
#import "ADLAPIRequests.h"
#import "ADLSingletonState.h"
#import "ADLNotifications.h"

@interface ADLFilterTypeTableViewController ()

@end

@implementation ADLFilterTypeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _typology = [[NSDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSString *bureauRef = [[ADLSingletonState sharedSingletonState] bureauCourant];
    
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:bureauRef, @"bureauRef", nil];
    
    API_REQUEST(@"getTypologie", args);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (IBAction)resetFilters:(id)sender {
    [[ADLSingletonState sharedSingletonState] setCurrentFilter:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFilterChanged object:nil];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_typology allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TypeCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   
    [[cell textLabel] setText:[[_typology allKeys] objectAtIndex: [indexPath row]]];
    
    return cell;
}


-(void)didEndWithRequestAnswer:(NSDictionary *)answer {
    NSDictionary *typologie = [[answer objectForKey:@"data"] objectForKey:@"typology"];
    
    _typology = [typologie retain];
    [((UITableView*)[self view]) reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];

    NSString *selectedKey = [[_typology allKeys] objectAtIndex: [indexPath row]];
    
    NSArray *subTypes = [_typology objectForKey:selectedKey];
    
    [[segue destinationViewController] setSubTypes:subTypes];
    [[ADLSingletonState sharedSingletonState] setCurrentFilter:[NSMutableDictionary dictionaryWithObjectsAndKeys:selectedKey,@"ph:typeMetier", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFilterChanged object:nil];

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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


@end
