//
//  HMSPeerConnection.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 11.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMSSessionDescription;
@class HMSStream;

NS_ASSUME_NONNULL_BEGIN

@interface HMSPeerConnection : NSObject

@property(nonatomic, copy, nullable) void (^onIceCandidate)(void);
@property(nonatomic, copy, nullable) void (^onAddStream)(HMSStream *);
@property(nonatomic, copy, nullable) void (^onRemoveStream)(void);
@property(nonatomic, assign) BOOL isOfferSent;
@property(nonatomic, copy) NSString *streamId;

- (nullable HMSSessionDescription *)localDescription;
- (void)setLocalDescription:(HMSSessionDescription *)localDescription completionHandler:(nullable void (^)(NSError *_Nullable error))completionHandler;

- (nullable HMSSessionDescription *)remoteDescription;
- (void)setRemoteDescription:(HMSSessionDescription *)remoteDescription completionHandler:(nullable void (^)(NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
