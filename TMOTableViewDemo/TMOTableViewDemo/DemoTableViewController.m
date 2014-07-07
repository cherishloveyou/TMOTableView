//
//  DemoTableViewController.m
//  TMOTableViewDemo
//
//  Created by 崔明辉 on 14-7-7.
//  Copyright (c) 2014年 多玩游戏. All rights reserved.
//

#import "DemoTableViewController.h"
#import "TMOTableView.h"

@interface DemoTableViewController ()<TMOLoadMoreControlDelegate, TMORefreshControlDelegate>

@property (nonatomic, assign) NSUInteger numberOfRowsInSection0;
@property (nonatomic, assign) NSUInteger numberOfRowsInSection1;
@property (strong, nonatomic) IBOutlet TMOTableView *tableView;

@end

@implementation DemoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.numberOfRowsInSection0 = 0;
        self.numberOfRowsInSection1 = 0;
    }
    return self;
}

//If you have to support iOS5, You have to use loadView

- (void)loadView {
    TMOTableView *theTableView = [[TMOTableView alloc] initWithFrame:self.navigationController.view.bounds];
    theTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    theTableView.delegate = self;
    theTableView.dataSource = self;
    self.view = theTableView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFirstLoad];//When set up finished, it will execute Immediately.
    [self setupRefreshControl];
    [self setupLoadMore];
    
//    self.tableView.myRefreshControl.delegate = self;//Set Delegate so customize refersh view.
//    self.tableView.myLoadMoreControl.delegate = self;//The same!
    
}

- (void)setupFirstLoad {
    UIView *customLoadingView = nil;
    UIView *customFailView = nil;//You can custom all Views.
    
//    {
//        customLoadingView = [[UIView alloc] initWithFrame:self.view.frame];
//        customLoadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        [customLoadingView setBackgroundColor:[UIColor grayColor]];
//    }
//    
//    {
//        customFailView = [[UIView alloc] initWithFrame:self.view.frame];
//        customFailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        [customFailView setBackgroundColor:[UIColor yellowColor]];
//    }
    
    [self.tableView firstLoadWithBlock:^(TMOTableView *tableView, DemoTableViewController *viewController) {
        //do something load data jobs
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (arc4random() % 10 < 3) {
                //We try to make load data jobs fail, and you can see what happen.
                [tableView.myFirstLoadControl fail];
            }
            else {
                viewController.numberOfRowsInSection0 = 5;
                viewController.numberOfRowsInSection1 = 8;
                [tableView.myFirstLoadControl done];//You don't need to use [tableView reloadData].
            }
        });
    } withLoadingView:customLoadingView withFailView:customFailView];
    
    self.tableView.myFirstLoadControl.allowRetry = YES;//set YES makes failView can response user tap retry. Default is NO.
}

- (void)setupRefreshControl {
    [self.tableView refreshWithCallback:^(TMOTableView *tableView, DemoTableViewController *viewController) {
        viewController.numberOfRowsInSection0 = arc4random() % 10;
        viewController.numberOfRowsInSection1 = arc4random() % 10;
        [tableView refreshDone];
    } withDelay:1.5];//Really easy to use.
    //Don't use self in block! Use tableView, viewController. It will 'Circular references'.
    //不要在Block中使用self!使用tableView和viewController代替，或者传入一个weak self，否则会导致循环引用。
}

- (IBAction)doRefresh:(id)sender {
    [self.tableView refreshAndScrollToTop];
}

- (void)setupLoadMore {
    [self.tableView loadMoreWithCallback:^(TMOTableView *tableView, DemoTableViewController *viewController) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (arc4random() % 10 < 4) {
                //try to fail
                tableView.myLoadMoreControl.isFail = YES;
            }
            else {
                viewController.numberOfRowsInSection1 += 10;
                [tableView loadMoreDone];
            }
        });
    } withDelay:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.numberOfRowsInSection0;
    }
    else if (section == 1) {
        return self.numberOfRowsInSection1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Cell:%d", indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Hello - %d", section];
}



//And now you can customize refreshView & loadMoreView
#pragma mark -
#pragma mark - TMORefreshControlDelegate

- (UIView *)refreshView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.tag = 1;
    progressView.frame = CGRectMake(0, 20, 320, 3);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        progressView.tintColor = [UIColor orangeColor];
    }
    [backgroundView addSubview:progressView];
    return backgroundView;
}

- (void)refreshViewInProcess:(UIView *)argCustomRefreshView withProcess:(CGFloat)argProcess {
    UIProgressView *progessView = (UIProgressView *)[argCustomRefreshView viewWithTag:1];
    [progessView setProgress:argProcess animated:NO];
}

- (void)refreshViewWillStartRefresh:(UIView *)argCustomRefreshView {
    UIProgressView *progessView = (UIProgressView *)[argCustomRefreshView viewWithTag:1];
    [progessView setProgress:1.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [progessView setTintColor:[UIColor greenColor]];
    }
}

- (void)refreshViewWillEndRefresh:(UIView *)argCustomRefreshView {
    UIProgressView *progessView = (UIProgressView *)[argCustomRefreshView viewWithTag:1];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [progessView setTintColor:[UIColor orangeColor]];
    }
    [progessView setProgress:0.0 animated:NO];
}

#pragma mark -
#pragma mark - TMOLoadMoreControlDelegate

- (UIView *)loadMoreView {
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
    [aLabel setBackgroundColor:[UIColor whiteColor]];
    [aLabel setTextAlignment:NSTextAlignmentCenter];
    [aLabel setFont:[UIFont systemFontOfSize:18.0]];
    [aLabel setText:@"有种你再拉啊！"];
    return aLabel;
}

- (void)loadMoreViewWillStartLoading:(UILabel *)argCustomView {
    [argCustomView setText:@"讨厌，人家正在加载更多啦"];
}

- (void)loadMoreViewWillEndLoading:(UILabel *)argCustomView {
    [argCustomView setText:@"有种你再拉啊！"];
}

- (void)loadMoreViewLoadFail:(UILabel *)argCustomView {
    [argCustomView setText:@"人家累啦！"];
}

@end
