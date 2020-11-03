//
//  HMSStreamInfoPrivate.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 17.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#ifndef HMSStreamInfoPrivate_h
#define HMSStreamInfoPrivate_h

@interface HMSStreamInfo(Private)
- (void)setTracks:(NSDictionary<NSString *,NSArray<HMSTrack *> *> * _Nonnull)tracks;
- (NSString *_Nullable)videoCodec;
- (void)setStreamId:(NSString *_Nonnull)streamId;
@end

#endif /* HMSStreamInfoPrivate_h */
