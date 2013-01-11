//
//  ADLActoinViewController.m
//  iParapheur
//
//  Created by Emmanuel Peralta on 13/10/12.
//
//

#import "ADLActionViewController.h"
#import "RGWorkflowDialogViewController.h"
#import "ADLSingletonState.h"
#import "ADLActionCell.h"

@interface ADLActionViewController ()

@end

@implementation ADLActionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
}

-(void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    if (_actions == nil) {
        _actions = [[NSMutableArray alloc] init];
    }
    else {
        [_actions removeAllObjects];
    }
    
    if (_labels == nil) {
        _labels = [[NSMutableArray alloc] init];
    }
    else {
        [_labels removeAllObjects];
    }
    
    if (self.signatureEnabled) {
        [_actions addObject:@"signature"];
        [_labels addObject:@"Signer"];
    }
    else if (self.visaEnabled) {
        [_actions addObject:@"viser"];
        [_labels addObject:@"Viser"];
    }
    
    [_actions addObject:@"reject"];
    [_labels addObject:@"Rejeter"];
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *dossierRef = [[ADLSingletonState sharedSingletonState] dossierCourant];
    if ([[segue identifier] isEqualToString:@"viser"]) {
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setDossierRef:dossierRef];
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setAction:[segue identifier]];
    }
    else if ([[segue identifier] isEqualToString:@"reject"]) {
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setDossierRef:dossierRef];
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setAction:[segue identifier]];        
    }
    else if ([[segue identifier] isEqualToString:@"signature"]) {
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setDossierRef:dossierRef];
        [((RGWorkflowDialogViewController*) [segue destinationViewController]) setAction:[segue identifier]];
    }
}


#pragma mark - UITableView datasource
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_actions count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADLActionCell* cell = (ADLActionCell*)[tableView dequeueReusableCellWithIdentifier:@"ActionCell"];
    
    if (cell == nil) {
        cell = [[ADLActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActionCell"];
    }
    
    [[cell actionLabel] setText:[_labels objectAtIndex:[indexPath row]]];
    if ([[_actions objectAtIndex:[indexPath row]] isEqualToString:@"reject"]) {
        UIImage *rejectImg = [UIImage imageNamed:@"rejeter.png"];
        [[cell imageView] setImage:rejectImg];
    }
    else {
        [[cell imageView] setImage:[UIImage imageNamed:@"viser.png"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:[_actions objectAtIndex:[indexPath row]] sender:self];
}




- (void)dealloc {
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
