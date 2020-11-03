//
//  HMSClient.h
//  HMSVideosdk
//
//  Created by Dmitry Fedoseyev on 10.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSPeer.h"
#import "HMSRoom.h"
#import "HMSStream.h"
#import "HMSMediaStreamConstraints.h"
#import "HMSCommonDefs.h"
#import "HMSStreamInfo.h"
#import "HMSClientConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HMSStreamResultHandler)(HMSStream * _Nullable stream, NSError * _Nullable error);

typedef NS_ENUM(NSUInteger, HMSLogLevel) {
    kHMSLogLevelOff = 0,
    kHMSLogLevelError = 1,
    kHMSLogLevelVerbose = 2
};

@protocol HMSLogger <NSObject>
- (void)logMessage:(NSString *)message withLogLevel:(HMSLogLevel)level;
@end

@interface HMSClient : NSObject

@property(nonatomic, copy) void (^onPeerJoin)(HMSRoom *, HMSPeer *);
@property(nonatomic, copy) void (^onPeerLeave)(HMSRoom *, HMSPeer *);
@property(nonatomic, copy) void (^onStreamAdd)(HMSRoom *, HMSPeer *, HMSStreamInfo *);
@property(nonatomic, copy) void (^onStreamRemove)(HMSRoom *, HMSStreamInfo *);
@property(nonatomic, copy) void (^onBroadcast)(HMSRoom *, HMSPeer *, NSDictionary *);
@property(nonatomic, copy) void (^onDisconnect)(NSError *_Nullable);
@property(nonatomic, assign) HMSLogLevel logLevel;
@property(nonatomic, strong) NSObject<HMSLogger> *logger;

- (instancetype)initWithPeer:(HMSPeer *)peer;
- (instancetype)initWithPeer:(HMSPeer *)peer config:(HMSClientConfig *_Nullable)config;

- (void)connect:(__nullable HMSOperationStatusHandler)completionHandler;
- (void)disconnect;

- (void)join:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;
- (void)leave:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;

- (HMSStream *)getLocalStream:(HMSMediaStreamConstraints *)constraints;

- (void)publish:(HMSStream *)stream room:(HMSRoom *)room completion:(__nullable HMSStreamResultHandler)completionHandler;
- (void)unpublish:(HMSStream *)stream room:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;

- (void)subscribe:(HMSStreamInfo *)stream room:(HMSRoom *)room completion:(__nullable HMSStreamResultHandler)completionHandler;
- (void)subscribe:(HMSStreamInfo *)stream room:(HMSRoom *)room bitrate:(NSInteger)bitrate completion:(__nullable HMSStreamResultHandler)completionHandler;
- (void)unsubscribe:(HMSStream *)stream room:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;

- (void)broadcast:(NSDictionary *)message room:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
