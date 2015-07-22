//
//  EM+MessageEmojiView.m
//  EaseMobUI
//
//  Created by 周玉震 on 15/7/3.
//  Copyright (c) 2015年 周玉震. All rights reserved.
//

#import "EM+ChatEmojiView.h"
#import "EmojiEmoticons.h"

#import "EM+Common.h"
#import "EM+ChatUIConfig.h"
#import "UIColor+Hex.h"

#define HORIZONTAL_COUNT (8)
#define VERTICAL_COUNT  (3)

@interface EM_ChatEmojiView()<UIScrollViewDelegate>

@end

@implementation EM_ChatEmojiView{
    NSArray *emojiArray;
    
    UIScrollView *scroll;
    NSMutableArray *indicatorArray;
    
    UIView *lineView;
    UIButton *latelyButton;
    UIButton *emojiButton;
    UIButton *sendButton;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        emojiArray = [EmojiEmoticons allEmoticons];
        
        scroll = [[UIScrollView alloc]init];
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.pagingEnabled = YES;
        scroll.delegate = self;
        [self addSubview:scroll];
        
        NSInteger pageEmojiCount = HORIZONTAL_COUNT * VERTICAL_COUNT - 1;
        for (int i = 0; i < emojiArray.count; i++) {
            UIButton *emoji = [[UIButton alloc]init];
            [emoji setTitle:emojiArray[i] forState:UIControlStateNormal];
            [emoji addTarget:self action:@selector(emojiClicked:) forControlEvents:UIControlEventTouchUpInside];
            [scroll addSubview:emoji];
            
            if (i % pageEmojiCount == pageEmojiCount - 1 || i == emojiArray.count - 1) {
                UIButton *deleteButton = [[UIButton alloc]init];
                [deleteButton setImage:[UIImage imageNamed:RES_IMAGE_TOOL(@"tool_delete")] forState:UIControlStateNormal];
                [deleteButton addTarget:self action:@selector(emojiDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
                [scroll addSubview:deleteButton];
            }
        }
        
        NSInteger count = emojiArray.count / (HORIZONTAL_COUNT * VERTICAL_COUNT - 1);
        if (emojiArray.count % (HORIZONTAL_COUNT * VERTICAL_COUNT - 1) > 0) {
            count += 1;
        }
        
        if (count > 1) {
            indicatorArray = [[NSMutableArray alloc]init];
            for (int i = 0; i < count; i++) {
                UIButton *indicatorItem = [[UIButton alloc]init];
                indicatorItem.tag = i;
                [indicatorItem addTarget:self action:@selector(indicatorClicked:) forControlEvents:UIControlEventTouchUpInside];
                if (i == 0) {
                    indicatorItem.backgroundColor = [UIColor grayColor];
                }else{
                    indicatorItem.backgroundColor = [UIColor whiteColor];
                }
                
                [indicatorArray addObject:indicatorItem];
                [self addSubview:indicatorItem];
            }
        }
        
        lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor colorWithHEX:LINE_COLOR alpha:1.0];
        [self addSubview:lineView];
        
        latelyButton = [[UIButton alloc]init];
        latelyButton.backgroundColor = self.backgroundColor;
        [latelyButton setTitle:@"最近" forState:UIControlStateNormal];
        [latelyButton setTitleColor:[UIColor colorWithHEX:TEXT_NORMAL_COLOR alpha:1.0] forState:UIControlStateNormal];
        [latelyButton setTitleColor:[UIColor colorWithHEX:TEXT_SELECT_COLOR alpha:1.0] forState:UIControlStateSelected];
        [latelyButton addTarget:self action:@selector(emojiLatelyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:latelyButton];
        
        emojiButton = [[UIButton alloc]init];
        emojiButton.backgroundColor = [UIColor colorWithHEX:LINE_COLOR alpha:1.0];
        emojiButton.selected = YES;
        [emojiButton setTitle:@"Emoji" forState:UIControlStateNormal];
        [emojiButton setTitleColor:[UIColor colorWithHEX:TEXT_NORMAL_COLOR alpha:1.0] forState:UIControlStateNormal];
        [emojiButton setTitleColor:[UIColor colorWithHEX:TEXT_SELECT_COLOR alpha:1.0] forState:UIControlStateSelected];
        [emojiButton addTarget:self action:@selector(emojiActionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:emojiButton];
        
        sendButton = [[UIButton alloc]init];
        sendButton.backgroundColor = [UIColor colorWithHEX:@"#A4D3EE" alpha:1.0];
        sendButton.selected = YES;
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor colorWithHEX:TEXT_NORMAL_COLOR alpha:1.0] forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor colorWithHEX:TEXT_SELECT_COLOR alpha:1.0] forState:UIControlStateSelected];
        [sendButton addTarget:self action:@selector(emojiSendClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    scroll.frame = CGRectMake(0, 0, size.width, (size.width - LEFT_PADDING - RIGHT_PADDING) / HORIZONTAL_COUNT * VERTICAL_COUNT);
    
    CGFloat actionX = LEFT_PADDING;
    CGFloat actionY = 0;
    CGFloat actionSize = scroll.frame.size.height / VERTICAL_COUNT;
    NSInteger actionPageIndex = 0;
    
    for (int i = 0; i < scroll.subviews.count; i++) {
        UIView *actionView = scroll.subviews[i];
        actionPageIndex = i / (HORIZONTAL_COUNT * VERTICAL_COUNT);
        if (i == scroll.subviews.count - 1) {
            actionX = scroll.frame.size.width * actionPageIndex + LEFT_PADDING + actionSize * (HORIZONTAL_COUNT - 1);
            actionY = actionSize * (VERTICAL_COUNT - 1);
        }else{
            actionX = scroll.frame.size.width * actionPageIndex + LEFT_PADDING + actionSize * (i % HORIZONTAL_COUNT);
            actionY = actionSize * (((i % (HORIZONTAL_COUNT * VERTICAL_COUNT) ) / HORIZONTAL_COUNT));
        }
        actionView.frame = CGRectMake(actionX, actionY, actionSize, actionSize);
    }
    
    if (indicatorArray && indicatorArray.count > 1) {
        scroll.contentSize = CGSizeMake(scroll.frame.size.width * indicatorArray.count, scroll.frame.size.height);
        
        CGFloat x = (size.width - HEIGHT_INDICATOR_OF_DEFAULT * indicatorArray.count - COMMON_PADDING * (indicatorArray.count - 1)) / 2;
        for (int i = 0; i < indicatorArray.count; i++) {
            UIView *subview = indicatorArray[i];
            subview.frame = CGRectMake(x + (HEIGHT_INDICATOR_OF_DEFAULT + COMMON_PADDING) * i, scroll.frame.size.height + HEIGHT_INDICATOR_OF_DEFAULT / 2, HEIGHT_INDICATOR_OF_DEFAULT, HEIGHT_INDICATOR_OF_DEFAULT);
            subview.layer.cornerRadius = HEIGHT_INDICATOR_OF_DEFAULT / 2;
        }
    }
    
    CGFloat toolHeight = (size.width - LEFT_PADDING - RIGHT_PADDING) / HORIZONTAL_COUNT;
    lineView.frame = CGRectMake(0, size.height - toolHeight, size.width, 0.5);
    latelyButton.frame = CGRectMake(0, size.height - toolHeight, size.width / 4, toolHeight);
    emojiButton.frame = CGRectMake(size.width / 4, size.height - toolHeight, size.width / 4, toolHeight);
    sendButton.frame = CGRectMake(size.width / 4 * 3, size.height - toolHeight, size.width / 4, toolHeight);
}

- (void)emojiClicked:(UIButton *)sender{
    if (_delegate) {
        [_delegate didEmojiClicked:sender.titleLabel.text];
    }
}

- (void)emojiDeleteClicked:(UIButton *)sender{
    if (_delegate) {
        [_delegate didEmojiDeleteClicked];
    }
}

- (void)emojiLatelyClicked:(UIButton *)sender{
    
}

- (void)emojiActionClicked:(UIButton *)sender{
    
}

- (void)emojiSendClicked:(UIButton *)sender{
    if (_delegate) {
        [_delegate didEmojiSendClicked];
    }
}

- (void)indicatorClicked:(UIButton *)sender{
    NSInteger pageIndex = sender.tag;
    if (pageIndex >= 0 && pageIndex < indicatorArray.count) {
        CGPoint offset = CGPointMake(scroll.frame.size.width * pageIndex, 0);
        [scroll setContentOffset:offset animated:YES];
        for (int i = 0; i < indicatorArray.count; i++) {
            UIView *subview = indicatorArray[i];
            if (i == pageIndex) {
                subview.backgroundColor = [UIColor grayColor];
            }else{
                subview.backgroundColor = [UIColor colorWithHEX:@"#FFF0F5" alpha:1.0];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    NSInteger pageIndex = offset.x / scrollView.frame.size.width;
    if (pageIndex >= 0 && pageIndex < indicatorArray.count) {
        for (int i = 0; i < indicatorArray.count; i++) {
            UIView *subview = indicatorArray[i];
            if (i == pageIndex) {
                subview.backgroundColor = [UIColor grayColor];
            }else{
                subview.backgroundColor = [UIColor whiteColor];
            }
        }
    }
}

@end