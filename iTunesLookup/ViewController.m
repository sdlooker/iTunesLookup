//
//  ViewController.m
//  iTunesLookup
//
//  Created by Shane Looker on 2/16/18.
//  Copyright © 2018 Shane Looker. All rights reserved.
//

#import "ViewController.h"
#import "QuickRest.h"

@interface ViewController () <UISearchBarDelegate, QuickRESTDataDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonnull) QuickREST *qr;

@property (weak, nonatomic) IBOutlet UITableViewController *tableController;
@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *resultsArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.qr = [[QuickREST alloc] initWithDelegate:self];    // Create the rest session handler

    // This is kind of skanky and depends on us knowing exactly what the hiereachy is going
    // to be when we load. But I want to keep all the data for the table here instead
    // of creating a controller subclass due to time constraints
    self.tableView = (UITableView*)[self.containerView.subviews firstObject];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Instead of setting up the full search bar controller, just put a search field and
// button in the storyboard. Not elegant.
- (IBAction)doSearch:(id)sender {
    [self.qr doSearchWithTerm:self.searchField.text ];
}

- (void)searchReturned:(NSDictionary *)dataDict {
    self.resultsArray = dataDict[@"results"];
    [self.tableView reloadData];
}


#pragma mark - Table support
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // The prototype is in the storyboard so we don't need to register the clas
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchResultsCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *item = self.resultsArray[indexPath.row];
    if (item[@"collectionCensoredName"] != nil) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", item[@"artistName"], item[@"collectionCensoredName"]];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", item[@"artistName"]];
    }
    cell.detailTextLabel.text = item[@"trackCensoredName"];
    // Get the image. This should cache the images using an LRU probably (NSCache) but
    // these should load on a background thread and update cells as needed on the main thread.
    // Also had to change default ATS level in info.plist to support http: protocol
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:item[@"artworkUrl100"]]];
    UIImage *tempImage = [UIImage imageWithData:imageData];
    cell.imageView.image = tempImage;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Push using seque to next view which shows lyrics, etc.
    // Not enough time
}

@end
