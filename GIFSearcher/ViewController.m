//
//  ViewController.m
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/24/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "ViewController.h"
#import "AXCGiphy.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    NSURLRequest *request = [AXCGiphy giphyTrendingRequestWithLimit:25.0 offset:0.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"RESPONSE >>>>>> %@", response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!error && httpResponse.statusCode == 200) {
                
            }
            else {
                //show error message
                NSLog(@"ERROR >>>>>>> %@", error.description);
                UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"Could Not Retrieve Books" message:@"Failed to retrieve the list of books. Please try again." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                [failAlert addAction:removeAlert];
                [self presentViewController:failAlert animated:YES completion:nil];
            }
        });
        
    }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
