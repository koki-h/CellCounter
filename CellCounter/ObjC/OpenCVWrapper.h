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

@interface OpenCVWrapper : NSObject
@property NSDictionary *param;
- (void) createCameraWithParentView:(UIImageView*) parentView;
- (void) start;
- (void) adjustParentViewAspect;
- (void) toggleCameraPosition;
@end

NS_ASSUME_NONNULL_END


#endif /* OpenCVWrapper_h */
