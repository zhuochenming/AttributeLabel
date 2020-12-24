//
//  ImagesViewController.m
//  CTView
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "ImagesViewController.h"
#import "CTView.h"
#import "UnderlineTextField.h"

@interface ImagesViewController ()<CTViewDelegate>

@end

@implementation ImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    
    CTView *label = [[CTView alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor lightGrayColor];
    label.delegate = self;
    label.lineSpacing = 5.0;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    [label appendImage:[UIImage imageNamed:@"hot"] size:CGSizeMake(100, 100) edge:UIEdgeInsetsMake(10, 100, 10, 100) alignment:kImageVerticalAlignmentCenter];
    
    NSString *text = @"\n嫣然，随风呢喃，一丝微意，送去炎炎夏日清爽。琴声悠长，盈满花田彝乡，水车轻摇，牧归唱晚。释怀！在拨片抚弄的时光中。心音靡靡，一弛一张，放开情缚千绳，荡过红尘，只留存缄默，不为飘逝的红颜静待。孤寂！在一朵茉莉的芬芳里睡去，梦里花落知多少？一点点销魂，一点点黯然，透过文墨，流淌在岁月的诗篇上。\n[haha][haha][haha][haha][haha][haha][haha]\n彝家小筑，满庭恬静，一壶米酒，三两碟农家小菜，小酌几许窃玉偷香的醉意，穿越指间青春划逝，曼舞轻歌，摇摆着内心悸动，回忆始燃。男孩的眼泪";
    
    NSInteger heheda = 1;
    NSArray *components = [text componentsSeparatedByString:@"[haha]"];
    NSUInteger count = [components count];
    for (NSUInteger i = 0; i < count; i++) {
        
        [label appendText:[components objectAtIndex:i]];
        
        if (i != count - 1) {
            UILabel *subLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 20)];
            subLable.tag = 1000 + i;
            subLable.text = @"我是UILable";
            subLable.textAlignment = NSTextAlignmentCenter;
            subLable.font = [UIFont systemFontOfSize:11];
            subLable.layer.cornerRadius = 5.0;
            subLable.textColor = [UIColor whiteColor];
            subLable.backgroundColor = [UIColor orangeColor];
            
            //圆角
            subLable.layer.cornerRadius = 5;
            subLable.clipsToBounds = YES;
            
            if (i == 1) {
                [label appendText:@"感觉的点点滴滴\n"];
            }
            
            [label appendView:subLable edge:UIEdgeInsetsMake(0, 5, 0, 5)];
            
            heheda++;
        }
    }
    [label appendImage:[UIImage imageNamed:@"hot"] size:CGSizeMake(100, 100) edge:UIEdgeInsetsMake(10, 100, 10, 100) alignment:kImageVerticalAlignmentCenter];
    [label appendText:@"\n"];
    
    [label appendImage:[UIImage imageNamed:@"hot"] size:CGSizeMake(100, 100) edge:UIEdgeInsetsMake(10, 100, 10, 100) alignment:kImageVerticalAlignmentTop];
    [label appendText:@"竹扇轻摇，轻舞心怡，是这个傍晚最真实的奢望，晚风拂柔，沐浴满院暖绪浅思的耳鬓厮磨，浓情暮意潜过心间，吹皱那湾深隐春潭。"];
    
//    CTView *lable = [[CTView alloc] initWithFrame:CGRectZero];
//    lable.delegate = self;
//    lable.lineSpacing = 5.0;
//    lable.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = CGRectGetWidth(self.view.frame) - 30;
    CGFloat height = [label getHeightWithWidth:width];
    label.frame = CGRectMake(15, 10, width, height);
    
    [scrollView addSubview:label];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, label.frame.size.height + 20);
}

- (void)tapView:(UIView *)view {
    NSLog(@"view");
}

- (void)tapImage:(UIImage *)image {
    NSLog(@"image");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardShow:(NSNotification *)notification {
    
}

- (void)keyboardHide:(NSNotification *)notification {
    
}

- (void)dismissKeyboard:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
