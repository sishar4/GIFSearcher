//
//  UISearchBar+RAC.m
//  GIFSearcher
//
//  Created by Sahil Ishar on 10/31/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "UISearchBar+RAC.h"
#import <objc/objc-runtime.h>

@interface UISearchBar()<UISearchBarDelegate>

@end

@implementation UISearchBar (RAC)

- (RACSignal *)rac_textSignal {
    self.delegate = self;
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;
    signal = [[self rac_signalForSelector:@selector(searchBar:textDidChange:) fromProtocol:@protocol(UISearchBarDelegate)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

@end
