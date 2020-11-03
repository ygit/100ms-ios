//
//  HMSPeer.h
//  HMSVideosdk
//
//  Created by Dmitry Fedoseyev on 10.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMSPeer : NSObject
@property (nonatomic, copy, readonly) NSString * peerId;
@property (nonatomic, copy, readonly) NSString * name;
@property (nonatomic, copy, nullable) NSString * authToken;

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name peerId:(NSString *)peerId;
@end

NS_ASSUME_NONNULL_END
