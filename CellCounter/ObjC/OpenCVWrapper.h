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
- (void) processDummyImage;
@end

NS_ASSUME_NONNULL_END


#endif /* OpenCVWrapper_h */
