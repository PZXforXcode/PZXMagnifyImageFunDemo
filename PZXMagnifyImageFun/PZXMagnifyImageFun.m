//
//  PZXMagnifyImageFun.m
//  PZXMagnifyImageFunDemo
//
//  Created by 彭祖鑫 on 2017/11/10.
//  Copyright © 2017年 PZX. All rights reserved.
//

#import "PZXMagnifyImageFun.h"


@interface PZXMagnifyImageFun ()<UIScrollViewDelegate>


///横向切换的滑动视图
@property (nonatomic,weak) UIScrollView *scrollView;
///记录上次查看的位置
@property (nonatomic,unsafe_unretained) CGPoint lastOffset;
///始、终做缩放动画的视图
@property (nonatomic,weak) UIImageView *animatImageView;
@property (nonatomic,strong) UIImageView *originalImageView;

@end

@implementation PZXMagnifyImageFun

+(void)PZXMagnifyImageWithImageView:(UIImageView *)imageView{
    
    UIView *superView = [UIApplication sharedApplication].delegate.window;
    CGRect frame = [imageView.superview convertRect:imageView.frame toView:superView];

    PZXMagnifyImageFun *PZXMagnifyImage = [[self alloc] initWithFrame:superView.frame];
    UIImageView *animatImageView = [[UIImageView alloc] initWithFrame:frame];
    [superView addSubview:animatImageView];
    PZXMagnifyImage.animatImageView = animatImageView;
    PZXMagnifyImage.originalImageView = imageView;
    PZXMagnifyImage.animatImageView.image = imageView.image;
    [superView addSubview:PZXMagnifyImage];
    
    frame = [PZXMagnifyImage frameWithImageView:imageView];
    
    [UIView animateWithDuration:0.5 animations:^{
        PZXMagnifyImage.animatImageView.frame = frame;
    } completion:^(BOOL finished) {
        //配置本类子控件属性
        PZXMagnifyImage.animatImageView.hidden = YES;
        PZXMagnifyImage.backgroundColor = [UIColor blackColor];
        //添加滑动视图
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:PZXMagnifyImage.frame];
        [PZXMagnifyImage addSubview:scrollView];
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        scrollView.delegate = PZXMagnifyImage;
        PZXMagnifyImage.scrollView = scrollView;
        PZXMagnifyImage.scrollView.contentSize = CGSizeMake(0, [UIScreen mainScreen].bounds.size.height);

        CGRect frame = [PZXMagnifyImage frameWithImageView:imageView];
        UIScrollView *miniScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [PZXMagnifyImage.scrollView addSubview:miniScrollView];
        miniScrollView.tag = 100 ;
        miniScrollView.maximumZoomScale = 10;
        miniScrollView.minimumZoomScale = 1;
        miniScrollView.delegate = PZXMagnifyImage;
        UIImageView *showImageView = [[UIImageView alloc] initWithFrame:frame];
        showImageView.tag = 50;
        [miniScrollView addSubview:showImageView];
        UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:PZXMagnifyImage action:@selector(oneTapGobackAction:)];
        [showImageView addGestureRecognizer:oneTap];
        UITapGestureRecognizer *twoTap = [[UITapGestureRecognizer alloc] initWithTarget:PZXMagnifyImage action:@selector(twoTapGobackAction:)];
        twoTap.numberOfTapsRequired = 2;
        [showImageView addGestureRecognizer:twoTap];
        [oneTap requireGestureRecognizerToFail:twoTap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:PZXMagnifyImage action:@selector(longPressAction:)];
        longPress.minimumPressDuration = 2.0;
        [showImageView addGestureRecognizer:longPress];
        showImageView.userInteractionEnabled = YES;
        //对图片进行等比例缩放，确保和 UIImageView 等宽或等高。
        showImageView.contentMode = UIViewContentModeScaleAspectFit;
        showImageView.image = imageView.image;
        
        //        }
        //        NSUInteger index = [imageViewer.imageViewsArray indexOfObject:willAnimatView];
        //        imageViewer.scrollView.contentOffset = CGPointMake(0, 0);
        //        imageViewer.lastOffset = imageViewer.scrollView.contentOffset;
        
    }];


}
#pragma mark Reuse
- (CGRect)frameWithImageView:(UIImageView *)imageView {//计算位置、处理超过屏幕宽的图片
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat x = 0;
    CGFloat y = 0;
    if (imageView.image.size.width >= [UIScreen mainScreen].bounds.size.width && imageView.image.size.height <= [UIScreen mainScreen].bounds.size.height) {//宽比屏幕大
        width = [UIScreen mainScreen].bounds.size.width;
        CGFloat widthScale = [UIScreen mainScreen].bounds.size.width / imageView.image.size.width;
        height = imageView.image.size.height * widthScale;
        y = ([UIScreen mainScreen].bounds.size.height - height) / 2;
    }else if (imageView.image.size.height >= [UIScreen mainScreen].bounds.size.height && imageView.image.size.width <= [UIScreen mainScreen].bounds.size.width) {//高比屏幕大
        height = [UIScreen mainScreen].bounds.size.height;
        CGFloat heightScale = [UIScreen mainScreen].bounds.size.height / imageView.image.size.height;
        width = imageView.image.size.width * heightScale;
        x = ([UIScreen mainScreen].bounds.size.width - width) / 2;
    }else if (imageView.image.size.width <= [UIScreen mainScreen].bounds.size.width && imageView.image.size.height <= [UIScreen mainScreen].bounds.size.height) {//宽高比屏幕小
        width = imageView.image.size.width;
        height = imageView.image.size.height;
        x = ([UIScreen mainScreen].bounds.size.width - width) / 2;
        y = ([UIScreen mainScreen].bounds.size.height - height) / 2;
    }else{//宽高比屏幕大
        width = [UIScreen mainScreen].bounds.size.width;
        CGFloat widthScale = [UIScreen mainScreen].bounds.size.width / imageView.image.size.width;
        height = imageView.image.size.height * widthScale;
        y = ([UIScreen mainScreen].bounds.size.height - height) / 2;
    }
    return CGRectMake(x, y, width, height);
}

#pragma mark Action
- (void)oneTapGobackAction:(UITapGestureRecognizer *)tap {//单击返回事件
    self.backgroundColor = [UIColor clearColor];
    NSInteger index = self.scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    UIScrollView *miniScrollView = [self.scrollView viewWithTag:100 + index];
    UIImageView *imageView = [miniScrollView viewWithTag: 50];
    imageView.hidden = YES;
    CGRect frame = [imageView.superview convertRect:imageView.frame toView:self.animatImageView.superview];
    self.animatImageView.hidden = NO;
    self.animatImageView.frame = frame;
    self.animatImageView.image = imageView.image;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *originalImageView = self.originalImageView;
    CGRect originalFrame = [originalImageView.superview convertRect:originalImageView.frame toView:self.animatImageView.superview];
    [UIView animateWithDuration:0.5 animations:^{
        self.animatImageView.frame = originalFrame;
    } completion:^(BOOL finished) {
        [self.animatImageView removeFromSuperview];
        [self removeFromSuperview];
    }];
}
- (void)twoTapGobackAction:(UITapGestureRecognizer *)tap {//双击缩放
    UIScrollView *scrollView = (UIScrollView *)tap.view.superview;
    static BOOL isZoom;
    isZoom = !isZoom;
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.zoomScale = (isZoom) ? 5 : 1;
    }];
}
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {//长按保存
    //    if (longPress.state == UIGestureRecognizerStateBegan) {
    //        UIImageWriteToSavedPhotosAlbum(((UIImageView *)longPress.view).image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    //    }
}
//- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {//保存成功后HUD提示
//    if (!error) {
//        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - [UIScreen mainScreen].bounds.size.width * 0.4) / 2, [UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.height * 0.1, [UIScreen mainScreen].bounds.size.width * 0.4, [UIScreen mainScreen].bounds.size.height / 20)];
//        bgView.tag = 888;
//        [self addSubview:bgView];
//        UIView *HUDView = [[UIView alloc] initWithFrame:bgView.bounds];
//        HUDView.alpha = 0.3;
//        HUDView.backgroundColor = [UIColor blackColor];
//        [bgView addSubview:HUDView];
//        UILabel *messageLabel = [[UILabel alloc] initWithFrame:bgView.bounds];
//        messageLabel.textColor = [UIColor whiteColor];
//        messageLabel.textAlignment = NSTextAlignmentCenter;
//        messageLabel.text = @"保存成功！";
//        [bgView addSubview:messageLabel];
//        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0];
//    }
//}

#pragma mark UIScrollViewDelegate
- (UIView* )viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.scrollView != scrollView) {
        //设置需要缩放的视图
        UIImageView *imageView = [scrollView viewWithTag:50];
        return imageView;
    }
    return nil;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.scrollView != scrollView) {
        //修改imageView缩放后的中心点位置
        UIImageView *imageView = [scrollView viewWithTag: 50];
        if (imageView.frame.size.width > scrollView.frame.size.width && imageView.frame.size.height > scrollView.frame.size.height) {
            imageView.center = CGPointMake(scrollView.contentSize.width / 2, scrollView.contentSize.height / 2);
        }else if (imageView.frame.size.width > scrollView.frame.size.width && imageView.frame.size.height <= scrollView.frame.size.height){
            imageView.center = CGPointMake(scrollView.contentSize.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
        }else if (imageView.frame.size.height > scrollView.frame.size.height && imageView.frame.size.width<=scrollView.frame.size.width){
            imageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, scrollView.contentSize.height / 2);
        }else{
            imageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollView == scrollView) {
        if (self.lastOffset.x != scrollView.contentOffset.x) {
            //重置上次查看的图片位置及大小，重置scrollView的缩放倍数
            UIScrollView *miniScrollView = [scrollView viewWithTag:self.lastOffset.x / [UIScreen mainScreen].bounds.size.width + 100];
            UIImageView *imageView = [miniScrollView viewWithTag:50];
            miniScrollView.zoomScale = 1.0f;
            imageView.frame = [self frameWithImageView:imageView];
            miniScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.lastOffset = scrollView.contentOffset;
        }
    }
}
@end
