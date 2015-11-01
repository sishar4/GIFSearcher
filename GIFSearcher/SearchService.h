//
//  SearchService.h
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/31/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SearchService : NSObject

+ (id)sharedInstance;

@property (nonatomic, retain) NSMutableArray *trendingGifArray;
@property (nonatomic, retain) NSMutableArray *tempSearchArray;
- (RACSignal *)search:(NSString *)text;

@end
