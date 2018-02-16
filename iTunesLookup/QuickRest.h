//
//  QuickRest.h
//  iTunesLookup
//
//  Created by Shane Looker on 2/16/18.
//  Copyright © 2018 Shane Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QuickRESTDataDelegate
- (void)searchReturned:(NSDictionary *)dataDict;
@end


@interface QuickREST : NSObject
- (instancetype)initWithDelegate:(id<QuickRESTDataDelegate>)delegate;
- (void)doSearchWithTerm:(NSString *)searchTerm;

@end

