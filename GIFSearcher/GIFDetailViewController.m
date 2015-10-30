//
//  GIFDetailViewController.m
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/24/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "GIFDetailViewController.h"

@implementation GIFDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Load GIF in web view
    NSURLRequest *request = [NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [_gifView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)shareGIF:(id)sender
{
    //Share GIF url
    NSMutableArray *packet = [[NSMutableArray alloc] initWithObjects:_url, nil];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:packet applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
@end
