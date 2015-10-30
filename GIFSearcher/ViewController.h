//
//  ViewController.h
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/24/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

