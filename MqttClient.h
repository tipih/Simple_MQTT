//
//  MqttClient.h
//  IOS_remote_controll
//
//  Created by Michael Rahr on 11/09/13.
//  Copyright (c) 2013 Michael Rahr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mqttDelegate.h"


@interface MqttClient : NSObject {
    struct mosquitto *mosq;
    NSString *host;
    unsigned short port;
    NSString *username;
    NSString *password;
    unsigned short keepAlive;
    BOOL cleanSession;
    NSTimer *timer;
    NSString* caFile;
    NSString* clientFile;
    NSString* clientKeyFile;
}

@property (strong,nonatomic) NSString *host;
@property (nonatomic,assign) unsigned short port;
@property (strong,nonatomic) NSString *username;
@property (strong,nonatomic) NSString *password;
@property (nonatomic,assign) unsigned short keepAlive;
@property (nonatomic,assign) BOOL cleanSession;
@property (weak, nonatomic)id <mqttDelegate> delegate;

+ (void) initialize;
+ (NSString*) version;

- (MqttClient*) initWithClientId: (NSString *)clientId;
- (void) setMessageRetry: (NSUInteger)seconds;
- (int) connect;
- (int) connectToHost: (NSString*)host;
- (void) reconnect;
- (void) disconnect;

- (void)setWill: (NSString *)payload toTopic:(NSString *)willTopic withQos:(NSUInteger)willQos retain:(BOOL)retain;
- (void)clearWill;

- (void)publishString: (NSString *)payload toTopic:(NSString *)topic withQos:(NSUInteger)qos retain:(BOOL)retain;

- (void)subscribe: (NSString *)topic;
- (void)subscribe: (NSString *)topic withQos:(NSUInteger)qos;
- (void)unsubscribe: (NSString *)topic;

// This is called automatically when connected
- (void) loop: (NSTimer *)timer;

@end
