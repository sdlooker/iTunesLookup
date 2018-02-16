//
//  QuickRest.m
//  iTunesLookup
//
//  Created by Shane Looker on 2/16/18.
//  Copyright © 2018 Shane Looker. All rights reserved.
//

#import "QuickRest.h"

@interface QuickREST () <NSURLSessionDelegate>
@property (strong, nonatomic) NSURLSession *session;
@property (weak, nonatomic) id<QuickRESTDataDelegate> delegate;
@property (strong, nonatomic) NSMutableData *totalData;
@end

@implementation QuickREST

- (instancetype)initWithDelegate:(id<QuickRESTDataDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        [self setupSession];
    }
    return self;
}

- (void)setupSession {
    
    NSURLSessionConfiguration *defConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:defConfig delegate:self delegateQueue:nil];
    
}

- (void)doSearchWithTerm:(NSString *)searchTerm {
    // Simple minded way to convert search components to + separated components. Won't work
    // well in real life. Needs to handle more cases
    NSString *searchOut = [searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // Build the URL as components.
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:@"https"];
    [components setHost:@"itunes.apple.com"];
    [components setPath:@"/search"];
    NSString *queryString = [NSString stringWithFormat:@"term=%@", [searchOut stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    [components setQuery:queryString];
    
    // fragment, host, password, path, port, query, queryItems, scheme, user,
    
    NSMutableURLRequest *firstURLReq = [NSMutableURLRequest requestWithURL:components.URL];
    firstURLReq.HTTPMethod = @"GET";  // or @"GET"
    
    // Now fire off the request, and process the completed results in the completion handler.
    NSURLSessionDataTask *dataTask = [self.session
                                      dataTaskWithURL:components.URL
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          NSError *jsonError = nil;
                                          id stuff = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                          //  Need to call the protocol method on the delegete on
                                          // the main thread because it does UI manipulation
                                          if ([stuff isKindOfClass:[NSDictionary class]]) {
                                              __weak typeof(self) weakSelf = self;
                                              dispatch_async(dispatch_get_main_queue(), ^() {
                                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                                  if (strongSelf) {
                                                      [strongSelf.delegate searchReturned:stuff];
                                                  }
                                              });
                                          } else {
                                              NSLog(@"Didn't get data dictionary back");
                                          }
                                          
                                      }];
    
    [dataTask resume];  // Start the task now that it is all set up
    
}

@end
