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

#import "OpenCVWrapper.h"
@interface
OpenCVWrapper() <CvVideoCameraDelegate> {
    CvVideoCamera *cvCamera;
    NSLock *_lock;
    NSDictionary *_param;

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
    cvCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    cvCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
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
    [_lock lock]; // スライダーを激しく動かしたときにアプリが落ちるのを防ぐため、排他制御する
    @try {
        //明るさによって二値化し、境界線を取得
        int th_lightness = [[_param objectForKey: @"th_lightness"] intValue];
        std::vector<std::vector<cv::Point>> contours =
            [self getLightnessContours:image th_lightness:th_lightness];

        // しきい値の範囲を外れる面積の輪郭線をカウントから除外する
        double th_area_min = [[_param objectForKey: @"th_area_min"] doubleValue];
        double th_area_max = [[_param objectForKey: @"th_area_max"] doubleValue];
        contours =
            [self contoursWithinArea:contours th_area_min:th_area_min th_area_max:th_area_max];

        // 最終的に残った境界線の個数が細胞の個数となる
        UIColor *contour_color = [_param objectForKey:@"contour_color"];
        cv::Scalar cv_contour_color = [self uiColorToCvScalarBGR:contour_color];
        image = [self drawContours:image contours:contours color:cv_contour_color]; //境界線を描画
        long cellcount = contours.size();
        NSDictionary *result = @{@"contours_count":  [NSNumber numberWithLong: cellcount]};
        [self.delegate didProcessImage: result];
    }
    @finally {
        [_lock unlock];
    }
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

- (std::vector<std::vector<cv::Point>>) getLightnessContours: (cv::Mat) src th_lightness: (int) th_lightness {
    cv::Mat dst;
    int l_threshold = th_lightness;
    dst = [self binarizeByLightness:src l_threshold:l_threshold];
    std::vector< std::vector<cv::Point> > contours;
    cv::findContours(dst, contours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    return contours;
}

- (cv::Mat) drawContours:(cv::Mat) canvas contours:(std::vector<std::vector<cv::Point>>) contours color:(cv::Scalar) color
{
    if (contours.size() > 1) {
        cv::drawContours(canvas, contours, -1, color,1);
    }
    return canvas;
}

- (cv::Mat) binarizeByLightness:(cv::Mat)src l_threshold:(int)l_threshold
{
    cv::Mat mid;
    cv::cvtColor(src, mid, CV_BGR2HLS);
    cv::GaussianBlur(mid, mid, cv::Size(5,5), 1);
    cv::Mat dst(src.rows,src.cols,CV_8UC1); // 結果保存用
    for (int y=0; y<dst.rows; y++) {
        for (int x=0; x < dst.cols; x++) {
            int index = (int) mid.step * y + (x * 3);
            int dst_index = (int) dst.step * y + x;
            int l = mid.data[index+1];
            if (l > l_threshold) {
                dst.data[dst_index] = 255;
            } else {
                dst.data[dst_index] = 0;
            }
        }
    }
    return dst;
}
@end
