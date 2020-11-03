//
//  HMSUtility.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 17.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSCommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

extern NSInteger const kHMSDefaultBitrate;

@interface HMSUtility : NSObject
+ (NSString *)codecStringFromCodec:(HMSVideoCodec)codec;
+ (HMSVideoCodec)codecFromString:(NSString *)string;

+ (NSString *)resolutionStringFromResolution:(HMSVideoResolution)resolution;
+ (HMSVideoResolution)resolutionFromResolutionString:(NSString *)string;
+ (CGSize)resolutionSizeFromResolution:(HMSVideoResolution)resolution;
@end

NS_ASSUME_NONNULL_END
