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
}




@end
