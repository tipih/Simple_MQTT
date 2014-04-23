//
//  mqttDelegate.h
//  IOS_remote_controll
//
//  Created by Michael Rahr on 11/09/13.
//  Copyright (c) 2013 Michael Rahr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MqttMessage.h"

@protocol mqttDelegate <NSObject>

//Must implement, this could and should be move to MqttCleint
@required
- (void) didConnect: (NSUInteger)code ipAddr:(NSString*)IPAddrString;
- (void) didDisconnect;
- (void) didPublish: (NSUInteger)messageId;

- (void) didReceiveMessage: (MqttMessage*)mosq_msg;
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos;
- (void) didUnsubscribe: (NSUInteger)messageId;



@end
