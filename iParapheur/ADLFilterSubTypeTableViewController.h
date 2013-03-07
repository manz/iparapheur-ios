//
//  ADLFilterSubTypeTableViewController.h
//  iParapheur
//
//  Created by Emmanuel Peralta on 21/02/13.
//
//

#import <UIKit/UIKit.h>

@interface ADLFilterSubTypeTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
- (IBAction)closeFilterPopover:(id)sender;

@property (nonatomic,retain) NSArray *subTypes;
@end
