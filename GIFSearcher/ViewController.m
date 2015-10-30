//
//  ViewController.m
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/24/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "ViewController.h"
#import "GIFDetailViewController.h"
#import "AXCGiphy.h"
#import "AXCGiphyImage.h"
#import "GifCell.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *gifsArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.gifsArray = [[NSMutableArray alloc] init];
    
    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    NSURLRequest *request = [AXCGiphy giphyTrendingRequestWithLimit:25.0 offset:0.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"RESPONSE >>>>>> %@", response);
        
        if (!error && httpResponse.statusCode == 200) {
            NSError *localError;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            NSDictionary *gifData = [parsedObject objectForKey:@"data"];
            
            for (NSDictionary *dict in gifData) {
                NSDictionary *imageDict = [dict objectForKey:@"images"];
                NSDictionary *imgDict = [imageDict objectForKey:@"fixed_height_still"];
                NSDictionary *gifDict = [imageDict objectForKey:@"fixed_height"];
                
                NSDictionary *gifs = [[NSDictionary alloc] initWithObjects:@[imgDict, gifDict] forKeys:@[@"image", @"gif"]];
                [self.gifsArray addObject:gifs];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        else {
            //show error message
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"ERROR >>>>>>> %@", error.description);
                UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"Could Not Retrieve GIFs" message:@"Failed to retrieve any GIFs. Please try again." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                [failAlert addAction:removeAlert];
                [self presentViewController:failAlert animated:YES completion:nil];
            });
        }
        
    }] resume];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gifsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GifCell *cell = (GifCell *)[tableView dequeueReusableCellWithIdentifier:@"gifCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GifCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *images = [self.gifsArray objectAtIndex:indexPath.row];
    AXCGiphyImage *gifImage = [[AXCGiphyImage alloc] initWithDictionary:[images objectForKey:@"image"]];

    NSLog(@"URL >> %@", gifImage.url);
    
    cell.imgView.image = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:gifImage.url];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    GifCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell)
                        updateCell.imgView.image = image;
                });
            }
        }
    });
    
    
    cell.layer.opaque = YES;
    cell.layer.shouldRasterize = YES;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *images = [self.gifsArray objectAtIndex:indexPath.row];
    AXCGiphyImage *gif = [[AXCGiphyImage alloc] initWithDictionary:[images objectForKey:@"gif"]];
    
    [self performSegueWithIdentifier:@"showGIFDetail" sender:gif];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 30)];
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    [label setTextColor:[UIColor blackColor]];
    [label setText:@"Trending"];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showGIFDetail"]) {
        GIFDetailViewController *detailVC = (GIFDetailViewController *)segue.destinationViewController;
        AXCGiphyImage *gifObj = (AXCGiphyImage *)sender;
        [detailVC setUrl:gifObj.url];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
