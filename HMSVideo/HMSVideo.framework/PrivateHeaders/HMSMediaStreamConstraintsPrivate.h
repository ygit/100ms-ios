//
//  HMSMediaStreamConstraintsPrivate.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 20.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#ifndef HMSMediaStreamConstraintsPrivate_h
#define HMSMediaStreamConstraintsPrivate_h

@interface HMSMediaStreamConstraints(Private)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end


#endif /* HMSMediaStreamConstraintsPrivate_h */
