//
//  ViewController.m
//  ExampleWithAutoLayout
//
//  Created by ziryanov on 31/10/13.
//  Copyright (c) 2013 ziryanov. All rights reserved.
//

#import "ViewController.h"
#import "DAKeyboardControl.h"

@interface ViewController () <UITableViewDataSource>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UIView *textAreaView;
@property (nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak ViewController *wself = self;
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if (opening)
        {
            CGPoint contentOffset = wself.tableView.contentOffset;
            contentOffset.y = MIN(contentOffset.y + keyboardFrameInView.size.height, wself.tableView.contentSize.height - (wself.tableView.frame.size.height - wself.tableView.contentInset.bottom));
            wself.tableView.contentOffset = contentOffset;
        }
    } constraintBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        wself.bottomConstraint.constant = wself.view.frame.size.height - keyboardFrameInView.origin.y;
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length + _textAreaView.frame.size.height + _bottomConstraint.constant, 0);
    self.view.keyboardTriggerOffset = _textAreaView.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %ld", indexPath.row + 1];
    return cell;
}

@end
