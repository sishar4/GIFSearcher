//
//  ViewController.h
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/24/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UISearchBar+RAC.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

