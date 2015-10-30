//
//  GIFDetailViewController.h
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/24/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFDetailViewController : UIViewController

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) IBOutlet UIWebView *gifView;
- (IBAction)shareGIF:(id)sender;

@end
