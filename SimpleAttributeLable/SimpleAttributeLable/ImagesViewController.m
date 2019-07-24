//
//  ImagesViewController.m
//  AttributedLabel
//
//  Created by Zhuochenming on 16/6/20.
//  Copyright © 2016年 Zhuochenming. All rights reserved.
//

#import "ImagesViewController.h"
#import "AttributedLabel.h"
#import "UnderlineTextField.h"

@interface ImagesViewController ()<AttributedLabelDelegate>

@end

@implementation ImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    AttributedLabel *lable = [[AttributedLabel alloc] initWithFrame:CGRectZero];
    lable.delegate = self;
    lable.lineSpacing = 5.0;
    lable.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    [lable appendImage:[UIImage imageNamed:@"hot"] size:CGSizeMake(100, 100) margin:UIEdgeInsetsMake(10, 100, 10, 100) alignment:kImageVerticalAlignmentCenter];
    
    NSString *text = @"\n嫣然，随风呢喃，一丝微意，送去炎炎夏日清爽。琴声悠长，盈满花田彝乡，水车轻摇，牧归唱晚。释怀！在拨片抚弄的时光中。心音靡靡，一弛一张，放开情缚千绳，荡过红尘，只留存缄默，不为飘逝的红颜静待。孤寂！在一朵茉莉的芬芳里睡去，梦里花落知多少？一点点销魂，一点点黯然，透过文墨，流淌在岁月的诗篇上。\n[haha]\n彝家小筑，满庭恬静，一壶米酒，三两碟农家小菜，小酌几许窃玉偷香的醉意，穿越指间青春划逝，曼舞轻歌，摇摆着内心悸动，回忆始燃。男孩的眼泪，在轻浮风中坠落，化茧才成蝶，蜕变成了男人的责任。从男孩变成男人的故事，飞舞在“彝人古镇”一尘不染的天空，纯真，捧不住最后那缕浪漫，留在了巷尾，风月仍在，情非远走。成长！寻觅了一段美丽伤痛的品尝，轻狂渐渐脱退，沾染了成熟后光阴的皱纹，责任！雪藏了此情已待成追忆。";
    
    NSInteger heheda = 1;
    NSArray *components = [text componentsSeparatedByString:@"[haha]"];
    NSUInteger count = [components count];
    for (NSUInteger i = 0; i < count; i++) {
        
        [lable appendText:[components objectAtIndex:i]];
        
        if (i != count - 1) {
//            UnderlineTextField *text = [[UnderlineTextField alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
//            text.text = [NSString stringWithFormat:@"%ld", heheda];
//            text.textAlignment = NSTextAlignmentCenter;
//            text.textColor = [UIColor lightGrayColor];
//            text.tag = 1000 + i;
//            [lable appendView:text];
            
            UILabel *subLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 270, 20)];
            subLable.tag = 1000 + i;
            subLable.text = @"我是UILable";
            subLable.textAlignment = NSTextAlignmentCenter;
            subLable.font = [UIFont systemFontOfSize:11];
            subLable.layer.cornerRadius = 5.0;
            subLable.textColor = [UIColor whiteColor];
            subLable.backgroundColor = [UIColor orangeColor];
            [lable appendView:subLable];
            
            heheda++;
        }
    }
    [lable appendImage:[UIImage imageNamed:@"hot"] size:CGSizeMake(100, 100) margin:UIEdgeInsetsMake(10, 100, 10, 100) alignment:kImageVerticalAlignmentCenter];
    [lable appendText:@"\n"];
    
    [lable appendImage:[UIImage imageNamed:@"hot"] size:CGSizeMake(100, 100) margin:UIEdgeInsetsMake(10, 100, 10, 100) alignment:kImageVerticalAlignmentTop];
    [lable appendText:@"竹扇轻摇，轻舞心怡，是这个傍晚最真实的奢望，晚风拂柔，沐浴满院暖绪浅思的耳鬓厮磨，浓情暮意潜过心间，吹皱那湾深隐春潭。"];
    
//    AttributedLabel *lable = [[AttributedLabel alloc] initWithFrame:CGRectZero];
//    lable.delegate = self;
//    lable.lineSpacing = 5.0;
//    lable.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = CGRectGetWidth(self.view.frame) - 30;
    CGFloat height = [lable getHeightWithWidth:width];
    lable.frame = CGRectMake(15, 10, width, height);
    [self.view addSubview:lable];
}

- (void)clickOnView:(UIView *)view {
    NSLog(@"view");
}

- (void)clickOnImage:(UIImage *)image {
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
