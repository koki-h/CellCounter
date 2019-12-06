//
//  OpenCVWrapper.mm
//  CellCounter
//
//  Created by koki on 2019/09/27.
//  Copyright © 2019 koki. All rights reserved.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"


#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/imgcodecs/ios.h>

#import "OpenCVWrapper.h"
@interface
OpenCVWrapper() <CvVideoCameraDelegate> {
    CvVideoCamera *cvCamera;
    NSLock *_lock;
    NSDictionary *_param;
    cv::Mat dummyImageMat; //デバッグモードで使用するダミー画像
}
@end

@implementation OpenCVWrapper

- (id)init {
    self = [super init];
    if (self) {
        // NSLock インスタンスを生成します。
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void) createCameraWithParentView:(UIImageView*) parentView {
    cvCamera = [[CvVideoCamera alloc] initWithParentView:parentView];
    cvCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    cvCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetPhoto;
    cvCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    cvCamera.defaultFPS = 30;
    cvCamera.grayscaleMode = NO;
    cvCamera.delegate = self;
}

- (void) start{
    [cvCamera start];
}

- (void) adjustParentViewAspect { // カメラ画像を表示するビューのアスペクト比を調整する
    //カメラの解像度を調べる
    AVCaptureInput *input = [cvCamera.captureSession.inputs objectAtIndex:0];
    AVCaptureInputPort *port = [input.ports objectAtIndex:0];
    CMFormatDescriptionRef formatDescription = port.formatDescription;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    int cameraHeight = dimensions.width;
    int cameraWidth = dimensions.height;
    NSLog( @"dimensions=%dx%d", dimensions.width, dimensions.height );
    if( cvCamera.parentView.layer.sublayers != nil ){
        CALayer *layer = [cvCamera.parentView.layer.sublayers objectAtIndex:0];
//        NSLog( @"[before] frame%@ position%@", NSStringFromCGRect(layer.frame), NSStringFromCGPoint(layer.position) );
        //現在のアスペクト比
        CGFloat ratiox = cameraWidth / layer.frame.size.width;
        CGFloat ratioy = cameraHeight / layer.frame.size.height;
        //contentModeによる表示サイズ/位置の決定
        switch( cvCamera.parentView.contentMode ){
            case UIViewContentModeScaleAspectFit:
                ratiox = (ratiox > ratioy)? ratiox : ratioy;
                ratioy = ratiox;
                break;
            case UIViewContentModeScaleAspectFill:
                ratiox = (ratiox < ratioy)? ratiox : ratioy;
                ratioy = ratiox;
                break;
            default:
                NSLog( @"does not support" );
                break;
        }
//        NSLog( @"ratio(%.3f,%.3f)", ratiox, ratioy );
        //新しい表示サイズ/位置をセット
        CGFloat x, y, w, h;
        w = cameraWidth / ratiox;
        h = cameraHeight / ratioy;
        x = (layer.frame.size.width - w)/2;
        y = (layer.frame.size.height - h)/2;
        layer.frame = CGRectMake( x, y, w, h );
//        NSLog( @"[after] frame%@ position%@", NSStringFromCGRect(layer.frame), NSStringFromCGPoint(layer.position) );
    }
}

- (void) toggleCameraPosition {
    [cvCamera switchCameras];
}

- (void)  setParam: (NSDictionary *) param {
    [_lock lock]; // スライダーを激しく動かしたときにアプリが落ちるのを防ぐため、排他制御する
    @try {
        _param = param;
    }
    @finally {
        [_lock unlock];
    }
}

- (void)processImage:(cv::Mat &)image {
    // カメラから取得した画像が引数に入る
    [self processImageInner:image];
}

- (void)processImageInner:(cv::Mat &)image {
    [_lock lock]; // スライダーを激しく動かしたときにアプリが落ちるのを防ぐため、排他制御する
    @try {
        //明るさによって二値化し、境界線を取得
        int th_lightness = [[_param objectForKey: @"th_lightness"] intValue];
        BOOL th_lightness_auto = [[_param objectForKey: @"th_lightness_auto"] intValue];
        cv::Mat preprocessed_image = [self preprocessForBinarize:image];
// for debug ↓ 前処理した画像を表示する
//        cv::cvtColor(preprocessed_image, image, CV_GRAY2BGR); // debug
// for degug ↑
        double otsu_th = 0;
        std::vector<std::vector<cv::Point>> contours =
            [self getLightnessContours:preprocessed_image th_lightness:th_lightness th_auto:th_lightness_auto otsu_th:&otsu_th];

        // しきい値の範囲を外れる面積の輪郭線をカウントから除外する
        double th_area_min = [[_param objectForKey: @"th_area_min"] doubleValue];
        double th_area_max = [[_param objectForKey: @"th_area_max"] doubleValue];
        contours =
            [self contoursWithinArea:contours th_area_min:th_area_min th_area_max:th_area_max];

        // 最終的に残った境界線の個数が細胞の個数となる
        UIColor *contour_color = [_param objectForKey:@"contour_color"];
        cv::Scalar cv_contour_color = [self uiColorToCvScalarBGR:contour_color];
        image = [self drawContours:image contours:contours color:cv_contour_color]; //境界線を描画
//        for debug↓ 画像全体が画面に表示されているかをチェックするために画像全体を囲む矩形を描画する
//        cv::Rect r = cv::Rect(0,0,image.cols,image.rows);
//        cv::rectangle(image, r, cv_contour_color,10);
//        for debug↑
        long cellcount = contours.size();
        NSDictionary *result = @{
            @"contours_count":  [NSNumber numberWithLong: cellcount],
            @"otsu_th": [NSNumber numberWithDouble: otsu_th]};
        
        [self.delegate didProcessImage: result];
    }
    @finally {
        [_lock unlock];
    }
}

- (cv::Mat) preprocessForBinarize: (cv::Mat) src {
    cv::Mat dst = src.clone();
    cv::cvtColor(dst, dst, CV_BGR2GRAY);
     // CLAHE (Contrast Limited Adaptive Histogram Equalization：適用的ヒストグラム平坦化)による平滑化
    cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE();
    clahe->setClipLimit(2);
    clahe->setTilesGridSize(cv::Size(8, 8));
    clahe->apply(dst, dst);
//    cv::GaussianBlur(dst, dst, cv::Size(5, 5), 1); // ガウシアンフィルタによる平滑化
//    cv::equalizeHist (dst, dst); // for debug 平滑化の効果を見るためにコントラストを強める
    return dst;
}

- (cv::Scalar) uiColorToCvScalarBGR: (UIColor*) color {
    double red;
    double green;
    double blue;
    double alpha;
    [color getRed: &red green: &green blue: &blue alpha: &alpha];
    int i_red = red * 255.0;
    int i_green = green * 255.0;
    int i_blue = blue * 255.0;
    return cv::Scalar(i_blue, i_green, i_red, alpha);
}

// Filters
- (std::vector<std::vector<cv::Point>>) contoursWithinArea: (std::vector<std::vector<cv::Point>>) contours th_area_min:(double) min th_area_max:(double) max {
    std::vector<std::vector<cv::Point>> contours_filtered = std::vector<std::vector<cv::Point>>();
    for(int i = 0 ; i < contours.size() ; ++i){
        std::vector<cv::Point> contour = contours[i];
        double area = cv::contourArea(contour);
        if ((min <= area) && (area <= max)) {
            contours_filtered.push_back(contour);
        }
    }
    return contours_filtered;
}

- (std::vector<std::vector<cv::Point>>) getLightnessContours: (cv::Mat) src th_lightness: (int) th_lightness th_auto: (BOOL) th_auto  otsu_th:(double *) otsu_th {
    cv::Mat dst;
    if (th_auto) {
        double th = cv::threshold(src, dst, 0, 255, cv::THRESH_BINARY + cv::THRESH_OTSU); //大津の2値化
        *otsu_th = th;
    } else {
        int l_threshold = th_lightness;
        cv::threshold(src, dst, l_threshold, 255, cv::THRESH_BINARY);
    }
    std::vector< std::vector<cv::Point> > contours;
    cv::findContours(dst, contours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    return contours;
}

- (cv::Mat) drawContours:(cv::Mat) canvas contours:(std::vector<std::vector<cv::Point>>) contours color:(cv::Scalar) color
{
    if (contours.size() > 1) {
        cv::drawContours(canvas, contours, -1, color,2);
    }
    return canvas;
}

// テスト用
//ダミー画像を使って画像処理する
- (UIImage *)processDummyImage {
    if (!self->dummyImageMat.data) {
        [self loadDummyImage];
    }
    cv::Mat mat = self->dummyImageMat;
    cv::cvtColor(mat, mat, CV_RGB2BGR);
    [self processImageInner:mat];
    cv::cvtColor(mat, mat, CV_BGR2RGB);
    UIImage* img = MatToUIImage(mat);
    return img;
}

- (void) loadDummyImage {
    UIImage* image = [UIImage imageNamed:@"dummyCellImage.jpg"];
    image = [self cropToFill:image frame:cvCamera.parentView.frame];
    UIImageToMat(image, self->dummyImageMat);    // UIImage -> cv::Mat
}

- (UIImage *) cropToFill: (UIImage *) image frame: (CGRect) r {
    //imageを解像度を変えずにトリミングしてrの枠に合わせる
    CGFloat height = 0.0;
    CGFloat width = 0.0;
    CGFloat tmp_height = image.size.width * (r.size.height / r.size.width);  // 画像の幅を維持する場合の画像の高さ
    CGFloat tmp_width = image.size.height * (r.size.width / r.size.height);  // 画像の高さを維持する場合の画像の幅
    if (image.size.height < image.size.width) {
        // 横長の画像の場合
        if (tmp_height > image.size.height) {
            // 幅を維持する場合の画像の高さが元の画像の高さを超えるときには画像の高さを維持して右側を切る
            height = image.size.height;
            width = tmp_width;
        } else {
            // 幅を維持する場合の画像の高さが元の画像の高さを超えないときには画像の幅を維持して下側を切る
            height = tmp_height;
            width = image.size.width;
        }
    } else {
        // 縦長の画像の場合
        if (tmp_width > image.size.width) {
            // 高さを維持する場合の画像の幅が元の画像の幅を超えるときには画像の幅を維持して下側を切る
            height = tmp_height;
            width = image.size.width;
        } else {
            // 高さを維持する場合の画像の幅が元の画像の幅を超えないときには画像の高さを維持して右側を切る
            height = image.size.height;
            width = tmp_width;
        }
    }
    CGRect new_rect = CGRectMake(0,0,width,height);
    image = [image partialImageOfRect:new_rect];
    return image;
}
@end
