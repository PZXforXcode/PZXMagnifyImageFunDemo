//
//  ViewController.m
//  PZXMagnifyImageFunDemo
//
//  Created by 彭祖鑫 on 2017/11/10.
//  Copyright © 2017年 PZX. All rights reserved.
//

#import "ViewController.h"
#import "PZXMagnifyImageFun.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageV;
- (IBAction)TAP:(UITapGestureRecognizer *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)TAP:(UITapGestureRecognizer *)sender {
    
    if (_imageV.image) {
        [PZXMagnifyImageFun PZXMagnifyImageWithImageView:_imageV];

    }
    
}
@end
