//
//  AppDelegate.h
//  MQTT_Simple_app
//
//  Created by Michael Rahr on 23/04/14.
//  Copyright (c) 2014 Rahr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MqttClient.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (readonly) MqttClient *mqttclient;
@property (strong, nonatomic) UIWindow *window;

@end
