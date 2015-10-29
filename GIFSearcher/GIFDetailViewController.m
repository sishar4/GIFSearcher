//
//  GIFDetailViewController.m
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/24/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "GIFDetailViewController.h"

@implementation GIFDetailViewController

- (IBAction)shareGIF:(id)sender
{
    //Share GIF url
    NSMutableArray *packet = [[NSMutableArray alloc] initWithObjects:@"", nil];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:packet applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
