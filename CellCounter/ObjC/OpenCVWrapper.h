//
//  OpenCVWrapper.h
//  CellCounter
//
//  Created by koki on 2019/09/27.
//  Copyright © 2019 koki. All rights reserved.
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h
#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIGraphics.h>
#import <UIKit/UIScreen.h>
#import <UIKit/UIImageView.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OpenCVWrapperDelegate <NSObject>
@optional
- (void)didProcessImage: (NSDictionary *)result;
@end

@interface OpenCVWrapper : NSObject
@property (weak, nonatomic) id <OpenCVWrapperDelegate> delegate;
- (void) createCameraWithParentView:(UIImageView *) parentView;
- (void) start;
- (void) adjustParentViewAspect;
- (void) toggleCameraPosition;
- (void) setParam:(NSDictionary *) param;
- (UIImage *) processDummyImage;
@end

@implementation UIImage (Custom)
- (UIImage *)partialImageOfRect:(CGRect)rect {
    // 画像を切り抜く
    CGPoint originDrawPoint = CGPointMake(rect.origin.x * -1, rect.origin.y * -1);

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    [self drawAtPoint:originDrawPoint];
    UIImage* partialImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return partialImage;
}
@end
NS_ASSUME_NONNULL_END


#endif /* OpenCVWrapper_h */
