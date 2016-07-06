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
    
    [lable appendImage:[UIImage imageNamed:@"hot"] size:CGSizeMake(100, 100) margin:UIEdgeInsetsMake(10, 100, 10, 100) alignment:ImageVerticalAlignmentCenter];
    
    NSString *text = @"\n说:哎，大中午的，也不休[haha]息，就开始[haha]在群里开车了，[haha]你们累不累呀\n";
    
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
            
            UILabel *subLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
            subLable.tag = 1000 + i;
            subLable.text = @"我是UILable";
            subLable.font = [UIFont systemFontOfSize:11];
            subLable.layer.cornerRadius = 5.0;
            subLable.textColor = [UIColor whiteColor];
            subLable.backgroundColor = [UIColor orangeColor];
            [lable appendView:subLable];
            
            heheda++;
        }
    }
    [lable appendImage:[UIImage imageNamed:@"hot"] size:CGSizeMake(100, 100) margin:UIEdgeInsetsMake(10, 100, 10, 100) alignment:ImageVerticalAlignmentCenter];
    
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
