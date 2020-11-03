//
//  HMSCommonDefs.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 10.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#ifndef HMSCommonDefs_h
#define HMSCommonDefs_h

typedef void (^HMSOperationStatusHandler)(BOOL isSuccess, NSError * _Nullable error);
typedef void (^HMSRequestCompletionHandler)(id _Nullable result, NSError * _Nullable error);

typedef NS_ENUM(NSUInteger, HMSVideoCodec) {
    kHMSVideoCodecH264,
    kHMSVideoCodecVP8,
    kHMSVideoCodecVP9
};

typedef NS_ENUM(NSUInteger, HMSVideoResolution) {
    kHMSVideoResolutionQVGA,
    kHMSVideoResolutionVGA,
    kHMSVideoResolutionSHD,
    kHMSVideoResolutionHD,
    kHMSVideoResolutionFullHD
};

#endif /* HMSCommonDefs_h */
