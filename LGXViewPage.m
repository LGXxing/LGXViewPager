//
//  LGXViewPage.m
//  MobileMap
//
//  Created by 兴哥哥 on 2017/10/27.
//  Copyright © 2017年 kingo. All rights reserved.
//

#import "LGXViewPage.h"
#ifdef DEBUG
#define DLog(s, ...) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog(s, ...)
#endif
@interface LGXViewPage ()
{
    NSArray *_titleArray;           /**< 菜单标题 */
    NSArray *_views;                /**< 视图 */
    NSArray *_titleIconsArray;      /**< 菜单标题左侧的小图标 */
    NSArray *_selectedIconsArray;   /**< 菜单被选中时左侧的小图标 */
    NSArray *_tipsCountArray;       /**< 菜单右上角的小红点显示的数量 */
}
@end
@implementation LGXViewPage
{
    SelectedBlock _block;
    NSInteger _pageNum;
}

//初始化
- (id)initWithFrame:(CGRect)frame
titles:(NSArray<NSString *> *)titles
views:(NSArray *)views
{
    self = [super initWithFrame:frame];
    if (self) {
        _views = views;
        _titleArray = titles;
        self.backgroundColor = [UIColor grayColor];
        [self configSelf];
    }
    return self;
}

- (void)setViewPagerTitles:(NSArray<NSString*>*)titles views:(NSArray*)views{
    _views = views;
    _titleArray = titles;
    [self configSelf];
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    
}
//设置默认属性
- (void)configSelf
{
    self.userInteractionEnabled = YES;
    _tabBgColor = [UIColor whiteColor];
    _tabArrowBgColor = [UIColor colorWithRed:204/255.0 green:208/255.0 blue:210/255.0 alpha:1];
    _tabTitleColor = [UIColor colorWithRed:12/255.0 green:134/255.0 blue:237/255.0 alpha:1];
    _tabSelectedBgColor = [UIColor whiteColor];
    _tabSelectedTitleColor = [UIColor colorWithRed:12/255.0 green:134/255.0 blue:237/255.0 alpha:1];
    _tabSelectedArrowBgColor =[UIColor colorWithRed:12/255.0 green:134/255.0 blue:237/255.0 alpha:1];
    _showVLine = YES;
    _showAnimation = YES;
    _showBottomLine = YES;
    _showSelectedBottomLine = YES;
    _enabledScroll = YES;
}

//视图重绘
- (void)drawRect:(CGRect)rect
{
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    // 视图控制器滑动视图
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 2, rect.size.width, rect.size.height - 2)];
    _scrollView.userInteractionEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    CGRect frame;
    frame.origin.y = 38;
    frame.size.height = _scrollView.frame.size.height - 40;
    frame.size.width = rect.size.width;
    
    //创建上方可滑动式图
    _pageControlScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, 40)];
    _pageControlScrollView.userInteractionEnabled = YES;
    _pageControlScrollView.showsHorizontalScrollIndicator = NO;
    _pageControlScrollView.showsVerticalScrollIndicator = NO;
    _pageControlScrollView.pagingEnabled = NO;
    _pageControlScrollView.directionalLockEnabled = YES;
    _pageControlScrollView.bounces = NO;
    if (_titleArray.count>=3) {
        _pageControlScrollView.contentSize = CGSizeMake((self.frame.size.width/3) * _titleArray.count, 40);
    }else{
    }
    _pageNum = _views.count;
    
    //创建菜单按钮下划线
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,  _pageControlScrollView.frame.size.height - 1, _pageControlScrollView.frame.size.width, 1)];
    label.backgroundColor = _tabArrowBgColor;
    [label sizeToFit];
    label.tag = 200;
    
    UILabel *selectedLabel = [[UILabel alloc] init];
    if (_pageNum>=3) {
        selectedLabel.frame = CGRectMake(_pageNum*(self.frame.size.width/3), _pageControlScrollView.frame.size.height -2, (self.frame.size.width/3), 2);
    }else{
        selectedLabel.frame = CGRectMake(_pageControlScrollView.frame.size.width, _pageControlScrollView.frame.size.height -2, _pageControlScrollView.frame.size.width/_pageNum, 2);
    }
    
    selectedLabel.backgroundColor = _tabSelectedArrowBgColor;
    selectedLabel.tag = 300;
    
    if (!_showBottomLine){
        CGRect labelFrame = label.frame;
        labelFrame.size.height = 0;
        label.frame = labelFrame;
    }
    
    if (!_showSelectedBottomLine) {
        CGRect selectedFrame = selectedLabel.frame;
        selectedFrame.size.height = 0;
        selectedLabel.frame = selectedFrame;
    }
    
    for (NSInteger i = 0; i < _views.count; i++) {
        //创建主视图
        UIView * view;
        
        if ([_views[i] isKindOfClass:[UIViewController class]]) {
            UIViewController *VC = _views[i];
            view = VC.view;
        }else{
            view = [_views objectAtIndex:i];
        }
        
        frame.origin.x = rect.size.width * i;
        [view setFrame:frame];
        [_scrollView addSubview:view];
        
        CGRect _pageframe = _pageControlScrollView.frame;
        if (_pageNum>=3) {
            _pageframe.size.width = rect.size.width / 3;
            
        }else{
            _pageframe.size.width = rect.size.width / _pageNum;
        }
        
        _pageframe.origin.x = _pageframe.size.width * i;
        
        //创建菜单按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:_pageframe];
        button.tag = 100 + i;
        [button setTitleColor:_tabTitleColor forState:UIControlStateNormal];
        [button setTitleColor:_tabSelectedTitleColor forState:UIControlStateSelected];
        [button setBackgroundColor:_tabBgColor];
        [button setTitle:_titleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:10];
        [button addTarget:self action:@selector(tabBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        //创建菜单右侧小图标
        if (_titleIconsArray.count) {
            [button setImage:_titleIconsArray[i] forState:UIControlStateNormal];
        }
        if (_selectedIconsArray.count) {
            [button setImage:_selectedIconsArray[i] forState:UIControlStateSelected];
        }
        DLog(@"titleLabel.frame:x:%lf width:%lf height:%lf",button.titleLabel.frame.origin.x,button.titleLabel.frame.size.width,button.titleLabel.frame.size.height);
        //创建菜单按钮右上角的小红点
        UILabel *circleLabel = [[UILabel alloc] initWithFrame:CGRectMake([self getLabelWidth:_titleArray[i] fontSize:15]/2+button.titleLabel.frame.origin.x, 2, 16, 16)];
        circleLabel.backgroundColor = [UIColor redColor];
        circleLabel.textColor = [UIColor whiteColor];
        circleLabel.font = [UIFont systemFontOfSize:12];
        circleLabel.textAlignment = NSTextAlignmentCenter;
        circleLabel.tag = 600 +i;
        circleLabel.layer.cornerRadius = 8;
        circleLabel.layer.masksToBounds = YES;
        circleLabel.clipsToBounds = YES;
        
        if (_tipsCountArray == nil || _tipsCountArray.count == 0) {
            circleLabel.hidden = YES;
        }else if ([_tipsCountArray[i] integerValue] <= 0){
            circleLabel.hidden = YES;
        }else{
            circleLabel.hidden = NO;
            circleLabel.text = [_tipsCountArray[i] integerValue]>99?@"99+":[NSString stringWithFormat:@"%@",_tipsCountArray[i]];
            CGPoint center = circleLabel.center;
            
            CGRect cFrame = circleLabel.frame;
            cFrame.size.width = [self getLabelWidth:circleLabel.text fontSize:12]+6>16?[self getLabelWidth:circleLabel.text fontSize:12]+6:16;
            
            circleLabel.frame = cFrame;
            circleLabel.center = center;
        }
        
        if (_showVLine) {
            //创建中间分割线
            UILabel *vlabel = [[UILabel alloc] initWithFrame:CGRectMake(-1, 10, 1, button.frame.size.height - 20)];
            vlabel.backgroundColor = _tabArrowBgColor;
            [button addSubview:vlabel];
            
            if (!i) {
                vlabel.hidden = YES;
            }
        }
        if (!i) {
            button.selected = YES;
        }
        if (button.selected) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect sframe = selectedLabel.frame;
                sframe.origin.x = button.frame.origin.x;
                selectedLabel.frame = sframe;
                [button setBackgroundColor:_tabSelectedBgColor];
            }];
        }
        [button addSubview:circleLabel];
        [_pageControlScrollView addSubview:button];
    }
    
    [_pageControlScrollView addSubview:label];
    [_pageControlScrollView addSubview:selectedLabel];
    
    if (_pageNum == 1) {
        // _pageControl.hidden = YES;
    }
    
    if (_enabledScroll) {
        [_scrollView setContentSize:CGSizeMake(rect.size.width * _views.count + 1, rect.size.height - 2)];
    }else{
        [_scrollView setContentSize:CGSizeZero];
    }
    _scrollView.delegate = self;
    
    [self addSubview:_scrollView];
    [self addSubview:_pageControlScrollView];
    
    self.scrollView.contentOffset = CGPointMake(self.frame.size.width*self.selectIndex, 0);
    
    [self setSelectIndex:self.selectIndex];
}

//按钮的点击事件
- (void)tabBtnClicked:(UIButton *)sender
{
    NSInteger index = sender.tag - 100;
    if (index>=1) {
        [_pageControlScrollView setContentOffset:CGPointMake((index-1)*self.frame.size.width/3,0) animated:YES];
    }
    if(index==_pageNum-1){
        [_pageControlScrollView setContentOffset:CGPointMake((index-2)*self.frame.size.width/3,0) animated:YES];
        
        
    }
    
    
    if (_showAnimation) {
        [UIView beginAnimations:@"navTab" context:nil];
        [UIView setAnimationDuration:0.3];
        [self setSelectIndex:index];
        _scrollView.contentOffset = CGPointMake(index * self.frame.size.width, 0);
        [UIView commitAnimations];
    }else{
        [self setSelectIndex:index];
        _scrollView.contentOffset = CGPointMake(index * self.frame.size.width, 0);
    }
}

//设置选择的按钮索引 触发的方法
- (void)setSelectIndex:(NSInteger)index
{
    if(_block){
        _block(self,index);
    }
    _selectIndex = index;
    for (NSInteger i = 0; i<_pageNum; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:i + 100];
        btn.backgroundColor = _tabBgColor;
        btn.selected = NO;
    }
    
    UIButton *button = (UIButton *)[_pageControlScrollView viewWithTag:index + 100];
    UILabel *selectedLabel = (UILabel *)[_pageControlScrollView viewWithTag:300];
    button.backgroundColor = _tabSelectedBgColor;
    button.selected = YES;
    
    if (_showAnimation) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = selectedLabel.frame;
            frame.origin.x = button.frame.origin.x;
            selectedLabel.frame = frame;
        }];
    }else{
        CGRect frame = selectedLabel.frame;
        frame.origin.x = button.frame.origin.x;
        selectedLabel.frame = frame;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_pageControlScrollView) {
        
    }
    NSInteger index = scrollView.contentOffset.x/self.frame.size.width;
    [self setSelectIndex:index];
    if (index>=1) {
        [_pageControlScrollView setContentOffset:CGPointMake((index-1)*self.frame.size.width/3,0) animated:YES];
    }
    if(index==_pageNum-1){
        [_pageControlScrollView setContentOffset:CGPointMake((index-2)*self.frame.size.width/3,0) animated:YES];
        
        
    }
    
}

- (void)setTabSelectedBgColor:(UIColor *)tabSelectedBgColor
{
    _tabSelectedBgColor = tabSelectedBgColor;
    [self setNeedsDisplay];
}

- (void)didSelectedBlock:(SelectedBlock)block
{
    _block = block;
}

- (NSInteger)getLabelWidth:(NSString *)string fontSize:(CGFloat)size
{
    CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]}];
    CGFloat width = stringSize.width;
    return width;
}

#pragma mark - version 2.0

- (id)initWithFrame:(CGRect)frame
titles:(NSArray<NSString *> *)titles
icons:(NSArray<UIImage *> *)icons
selectedIcons:(NSArray<UIImage *> *)selectedIcons
views:(NSArray *)views
{
    self = [super initWithFrame:frame];
    if (self) {
        _views = views;
        _titleArray = titles;
        _titleIconsArray = icons;
        _selectedIconsArray = selectedIcons;
        self.backgroundColor = [UIColor grayColor];
        [self configSelf];
    }
    return self;
}

- (void)setTitleIconsArray:(NSArray<UIImage *> *)icons
selectedIconsArray:(NSArray<UIImage *> *)selectedIcons
{
    _titleIconsArray = icons;
    _selectedIconsArray = selectedIcons;
    [self setNeedsDisplay];
}

//设置菜单标题右上角小红点上显示的数字
- (void)setTipsCountArray:(NSArray *)tips
{
    _tipsCountArray = tips;
    [self setNeedsDisplay];
}
@end

