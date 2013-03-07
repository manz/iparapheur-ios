//
//  ADLFilterTypeTableViewController.h
//  iParapheur
//
//  Created by Emmanuel Peralta on 21/02/13.
//
//

#import <UIKit/UIKit.h>
#import "ADLParapheurWallDelegateProtocol.h"

@interface ADLFilterTypeTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, ADLParapheurWallDelegateProtocol>

@property (retain, nonatomic) NSDictionary *typology;

- (IBAction)resetFilters:(id)sender;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)didEndWithRequestAnswer:(NSDictionary *)answer;

@end
