//
//  SearchService.m
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/31/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "SearchService.h"
#import "AXCGiphy.h"

@implementation SearchService

typedef void(^CompletedResults)(NSMutableArray *searchResults, NSError *error);

+ (id)sharedInstance
{
    static SearchService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.trendingGifArray = [[NSMutableArray alloc] init];
        sharedInstance.tempSearchArray = [[NSMutableArray alloc] init];
    });
    
    return sharedInstance;
}

- (void)search:(NSString *)text completed:(CompletedResults)handler {
    if (self.tempSearchArray == nil) {
        self.tempSearchArray = [[NSMutableArray alloc] init];
    }
    [self.tempSearchArray removeAllObjects];
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSURLRequest *request = [AXCGiphy giphySearchRequestForTerm:text limit:100.0 offset:0.0];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"RESPONSE >>>>>> %@", response);
            
            if (!error && httpResponse.statusCode == 200) {
                NSError *localError;
                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                NSDictionary *gifData = [parsedObject objectForKey:@"data"];
                
                for (NSDictionary *dict in gifData) {
                    NSDictionary *imageDict = [dict objectForKey:@"images"];
                    NSDictionary *imgDict;
                    NSDictionary *gifDict;
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        imgDict = [imageDict objectForKey:@"original_still"];
                        gifDict = [imageDict objectForKey:@"original"];
                    } else {
                        imgDict = [imageDict objectForKey:@"fixed_height_still"];
                        gifDict = [imageDict objectForKey:@"fixed_height"];
                    }
                    
                    
                    NSDictionary *gifs = [[NSDictionary alloc] initWithObjects:@[imgDict, gifDict] forKeys:@[@"image", @"gif"]];
                    [self.tempSearchArray addObject:gifs];
                }
                //return array of gifs for the search term
                if (handler){
                    handler(self.tempSearchArray, nil);
                }
            }
            else {
                //show error message
                if (handler){
                    handler(nil, error);
                }
            }
            
        }] resume];
    });
}

- (RACSignal *)search:(NSString *)text {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [self search:text completed:^(NSMutableArray *searchResult, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:searchResult];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

- (void)getTrendingGifsWithCompletionHandler:(void (^)(NSMutableArray *, BOOL))completionHandler {
    
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
                NSDictionary *imgDict;
                NSDictionary *gifDict;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    imgDict = [imageDict objectForKey:@"original_still"];
                    gifDict = [imageDict objectForKey:@"original"];
                } else {
                    imgDict = [imageDict objectForKey:@"fixed_height_still"];
                    gifDict = [imageDict objectForKey:@"fixed_height"];
                }
                
                
                NSDictionary *gifs = [[NSDictionary alloc] initWithObjects:@[imgDict, gifDict] forKeys:@[@"image", @"gif"]];
                [self.trendingGifArray addObject:gifs];
            }
            //return the array of trending gifs
            completionHandler(self.trendingGifArray, YES);
        }
        else {
            //show error message
            NSLog(@"ERROR >>>>>>> %@", error.description);
            completionHandler(nil, NO);
        }
        
    }] resume];
}

@end
