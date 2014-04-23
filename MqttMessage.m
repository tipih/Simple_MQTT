//
//  MqttMessage.m
//  IOS_remote_controll
//
//  Created by Michael Rahr on 12/09/13.
//  Copyright (c) 2013 Michael Rahr. All rights reserved.
//

#import "MqttMessage.h"

@implementation MqttMessage
@synthesize mid, topic, payload, payloadlen, qos, retained;

-(id)init
{
    self.mid = 0;
    self.topic = nil;
    self.payload = nil;
    self.payloadlen = 0;
    self.qos = 0;
    self.retained = FALSE;
    return self;
}

@end


