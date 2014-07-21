//
//  MessagesViewController.m
//  IMApp
//
//  Created by chen on 14-7-21.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "MessagesViewController.h"

@interface MessagesViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate>
{
    UISearchBar *_searchB;
    UITableView *_tableV;
    NSMutableArray *_arData;
    UISegmentedControl *_selectTypeSegment;
    UISearchDisplayController *_searchDisplayC;
}

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createNavWithTitle:nil createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
             UIImage *i = [UIImage imageNamed:@"menu_icon_bulb.png"];
             [btn setImage:i forState:UIControlStateNormal];
             [btn setFrame:CGRectMake(self.navView.width - i.size.width - 10, (self.navView.height - i.size.height)/2, i.size.width, i.size.height)];
             
             return btn;
         }
         return nil;
     }];
    _searchB = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navView.bottom, self.view.width, 44)];
//    [_searchB setShowsCancelButton:YES animated:YES];
    [_searchB setPlaceholder:@"搜索"];
    [_searchB setSearchBarStyle:UISearchBarStyleDefault];
//    [self.view addSubview:_searchB];
    
    _selectTypeSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"消息", @"通话", nil]];
    [_selectTypeSegment setFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 120)/2, 8, 120, 28)];
    [_selectTypeSegment setSelectedSegmentIndex:0];
    [self.navView addSubview:_selectTypeSegment];
    
    _tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, _searchB.bottom, CGRectGetWidth(self.view.frame), self.view.height - _searchB.bottom - self.tabBarController.tabBar.height) style:UITableViewStylePlain];
    _tableV.dataSource = self;
    _tableV.delegate = self;
    [self.view addSubview:_tableV];
    
    _searchDisplayC = [[UISearchDisplayController alloc] initWithSearchBar:_searchB contentsController:self];
//    [searchDisplayC setActive:YES animated:YES];
    _searchDisplayC.active = NO;
    _searchDisplayC.delegate = self;
    _searchDisplayC.searchResultsDataSource =self;
    _searchDisplayC.searchResultsDelegate =self;
    [self.view addSubview:_searchDisplayC.searchBar];
    
    [self initData];
}

- (void)initData
{
    __async_opt__, ^
    {
        _arData = [NSMutableArray new];
        
        [_arData addObject:@"好友A"];
        [_arData addObject:@"陌生人C"];
        [_arData addObject:@"我的电脑"];
        [_arData addObject:@"群B"];
        
        __async_main__, ^
        {
            [_tableV reloadData];
        });
    });
}

#pragma mark - action

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _searchDisplayC.searchResultsTableView)
    {
        return 0;
    }
    return [_arData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [_arData objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchDisplayDelegate

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [UIView animateWithDuration:0.2 animations:^
     {
         self.navView.top -= 64;
         _searchB.top -= 44;
         _tableV.top -= 44;
     }completion:^(BOOL finished)
    {
        [self.navView setHidden:YES];
        _tableV.height += 44;
     }];
    
    //不成功
    UISearchBar *searchBar = self.searchDisplayController.searchBar;
    for(UIView *subView in ((UIView *)[searchBar.subviews objectAtIndex:0]).subviews)
    {
        if([subView isKindOfClass:UIButton.class])
        {
            [(UIButton*)subView setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.navView setHidden:NO];
    [UIView animateWithDuration:0.2 animations:^
    {
         self.navView.top += 64;
        _searchB.top += 44;
        _tableV.top += 44;
    }completion:^(BOOL finished)
    {
        _tableV.height -= 44;
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filteredListContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
//    [self filterContentForSearchText:searchString];
//
//    if ([filteredListPinYin count] == 0) {

        UITableView *tableView1 = self.searchDisplayController.searchResultsTableView;

        for( UIView *subview in tableView1.subviews )
        {
            if( [subview class] == [UILabel class] )
            {
                UILabel *lbl = (UILabel*)subview; // sv changed to subview.
                lbl.text = @"没有结果";
                return YES;
            }
        }
//    }
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filteredListContentForSearchText:[self.searchDisplayController.searchBar text] scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];

    return YES;
}

#pragma mark Content Filtering

- (void)filteredListContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    //    if(nil==m_filteredListContent)
    //        m_filteredListContent=[NSMutableArray new];
    //    [m_filteredListContent removeAllObjects];
    //
    //    for(NSString* str in groups)
    //    {
    //        NSArray * contactSection = [contactTitles objectForKey:str];
    //        for (NSMutableDictionary *eObj in contactSection)
    //        {
    //            if ([[[eObj objectForKey:@"name"] uppercaseString] rangeOfString:[searchText uppercaseString]].length>0)
    //            {
    //                [m_filteredListContent addObject:eObj];
    //            }
    //        }
    //    }
}

@end