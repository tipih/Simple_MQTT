//
//  MqttMessage.h
//  IOS_remote_controll
//
//  Created by Michael Rahr on 12/09/13.
//  Copyright (c) 2013 Michael Rahr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MqttMessage : NSObject


@property (nonatomic, assign) unsigned short mid;
@property (readwrite, strong) NSString *topic;
@property (readwrite, strong) NSString *payload;
@property (nonatomic, assign) unsigned short payloadlen;
@property (nonatomic, assign) unsigned short qos;
@property (nonatomic, assign) BOOL retained;

-(id)init;
@end
