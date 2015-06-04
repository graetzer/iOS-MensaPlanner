//
//  SGViewController.h
//  SGViewPager
//
//  Copyright (c) 2012-2015 Simon Grätzer
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SGViewPagerController.h"

@interface SGAnnotatedPagerController : UIViewController <UIScrollViewDelegate> {
    NSUInteger _pageIndex;
    BOOL _lockPageChange;
}

@property (readonly, nonatomic) UIScrollView *titleScrollView;
@property (readonly, nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSUInteger pageIndex;

- (void)reloadPages;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;//TODO animations
- (void)setPageIndex:(NSUInteger)index animated:(BOOL)animated;

@end
