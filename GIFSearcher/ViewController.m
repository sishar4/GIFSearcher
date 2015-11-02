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
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SearchService.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *gifsArray;
@property (nonatomic, strong) NSMutableArray *trendingGifArray;
@property (nonatomic, assign) BOOL userSearching;
@property (nonatomic, strong) NSString *currentSearchText;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    self.gifsArray = [[NSMutableArray alloc] init];
    self.trendingGifArray = [[NSMutableArray alloc] init];
    SearchService *sharedSearchService = [SearchService sharedInstance];
    __weak ViewController *weakSelf = self;
    
    
    //SEARCH BAR TEXT DID CHANGE
    RACSignal *searchTextSignal = self.searchBar.rac_textSignal;
    [[[[[searchTextSignal throttle:0.4]
        map:^id(NSString* searchText) {
            NSLog(@"Text after throttle >> %@", searchText);
            _currentSearchText = searchText;
            /*
             Clicking on clear or emptying search text field will remove GIFs from search
             and return to list of trending GIFs
             */
            if (searchText.length == 0) {
                weakSelf.userSearching = NO;
                [weakSelf.gifsArray removeAllObjects];
                [weakSelf.gifsArray addObjectsFromArray:self.trendingGifArray];
                [weakSelf.tableView reloadData];
                return nil;
            }
            
            return [sharedSearchService search:searchText];
        }]
       switchToLatest] deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSMutableArray* searchResult) {
         if ([NSThread isMainThread]){
             NSLog(@"is MainThread");
             if (weakSelf.userSearching == NO) {
                 weakSelf.userSearching = YES;
             }
             [weakSelf.gifsArray removeAllObjects];
             [weakSelf.tableView reloadData];
         }
         NSLog(@"searchResult count == %lu",(unsigned long)searchResult.count);
    } error:^(NSError *error) {
        if ([NSThread isMainThread]) {
            NSLog(@"ERROR >>>>>>> %@", error.description);
            UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"Could Not Retrieve GIFs" message:@"Failed to retrieve any GIFs. Please try again." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [failAlert addAction:removeAlert];
            [self presentViewController:failAlert animated:YES completion:nil];
        }
    }];
    

    //SEARCH BAR SEARCH BUTTON CLICKED
    RACSignal *searchClicked = [self.searchBar rac_signalForSelector:@selector(searchBarSearchButtonClicked:)];
    [searchClicked subscribeNext:^(id _) {
        [weakSelf.searchBar resignFirstResponder];
        // Complete the search
        [weakSelf.gifsArray removeAllObjects];
        [weakSelf.gifsArray addObjectsFromArray:sharedSearchService.tempSearchArray];
        [weakSelf.tableView reloadData];
        NSLog(@"Search Clicked.");
    }];
    
    //SEARCH BAR CANCEL BUTTON CLICKED
    RACSignal *cancelSearchClicked = [self.searchBar rac_signalForSelector:@selector(searchBarCancelButtonClicked:)];
    [cancelSearchClicked subscribeNext:^(id _) {
        if (_currentSearchText.length > 0) {
            [weakSelf.searchBar setText:_currentSearchText];
        } else {
            [weakSelf.searchBar setText:@""];
        }
        [weakSelf.searchBar resignFirstResponder];
        NSLog(@"Search Cancelled.");
    }];

    //Get Trending Gifs
    [sharedSearchService getTrendingGifsWithCompletionHandler:^(NSMutableArray *results, BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.gifsArray addObjectsFromArray:results];
                [self.tableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"Could Not Retrieve GIFs" message:@"Failed to retrieve any GIFs. Please try again." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                [failAlert addAction:removeAlert];
                [self presentViewController:failAlert animated:YES completion:nil];
            });
        }
    }];
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 304.0;
    } else {
        return 200.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 30)];
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    [label setTextColor:[UIColor blackColor]];
    if (!_userSearching) {
        [label setText:@"Trending"];
    } else {
        SearchService *sharedObj = [SearchService sharedInstance];
        [label setText:[NSString stringWithFormat:@"%lu GIFs for \"%@\"", sharedObj.tempSearchArray.count, _currentSearchText]];
    }
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
