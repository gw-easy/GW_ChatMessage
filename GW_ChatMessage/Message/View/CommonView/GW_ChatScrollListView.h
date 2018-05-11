//
//  GW_ChatScrollListView.h
//  GW_ChatMessage
//
//  Created by gw on 2018/5/3.
//  Copyright © 2018年 gw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GW_ChatScrollListView : UIView
@property (strong, nonatomic)UIView *topLine;
@property (strong, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *emotions;
@property (strong, nonatomic) NSArray *picEmotions;
@property (strong, nonatomic) NSArray *moreItem;
- (void)scrollToTopAcrion;
@end
