//
//  UISearchBar+RAC.h
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/31/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface UISearchBar (RAC)

- (RACSignal *)rac_textSignal;

@end
