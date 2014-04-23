//
//  MqttClient.m
//  IOS_remote_controll
//
//  Created by Michael Rahr on 11/09/13.
//  Copyright (c) 2013 Michael Rahr. All rights reserved.
//

#import "MqttClient.h"
#import "mosquitto.h"
#import "mqtt_strings.h"
#import "MqttMessage.h"
#import "GlobalStrings.h"
#import <sys/sysctl.h>


@implementation MqttClient

@synthesize host;
@synthesize port;
@synthesize username;
@synthesize password;
@synthesize keepAlive;
@synthesize cleanSession;
#define trace_on

- (NSString *)platformRawString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];

    return platform;
}



- (NSString *)platformNiceString {
    NSString *platform = [self platformRawString];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (wifi)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad 3 (MINI)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (4G,2)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (4G,3)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}




static void on_connect(struct mosquitto *mosq, void *obj, int rc)
{
    MqttClient* client = (__bridge MqttClient*)obj;
#ifdef trace_on
    NSLog(@"MQTTCLIENT: Connect");
#endif
    [[client delegate] didConnect:(NSUInteger)rc ipAddr:(NSString*)client.host];
    
}

static void on_disconnect(struct mosquitto *mosq, void *obj, int rc)
{
    MqttClient* client = (__bridge MqttClient*)obj;
#ifdef trace_on
    NSLog(@"MQTTCLIENT: Disconnect");
#endif
    [[client delegate] didDisconnect];
}

static void on_publish(struct mosquitto *mosq, void *obj, int message_id)
{
    MqttClient* client = (__bridge MqttClient*)obj;
//#ifdef trace_on
    NSLog(@"MQTTCLIENT: Publish %d",message_id);
//#endif
    [[client delegate] didPublish:(NSUInteger)message_id];
}

static void on_message(struct mosquitto *mosq, void *obj, const struct mosquitto_message *message)
{
#ifdef trace_on
 NSLog(@"MQTTCLIENT: message received, pass the data to the delegate");
#endif
    MqttMessage* mosq_msg = [[MqttMessage alloc] init];
    
    mosq_msg.topic = [NSString stringWithUTF8String: message->topic];
#ifdef trace_on
    NSLog(@"MQTTCLIENT tropic = %@",mosq_msg.topic);
#endif
    if (message->payloadlen >0)
     mosq_msg.payload = [NSString stringWithUTF8String: message->payload];
    else
     mosq_msg.payload = @"";
    
    MqttClient* client = (__bridge MqttClient*)obj;
     [[client delegate] didReceiveMessage:mosq_msg];
   

    //[[client delegate] didReceiveMessage:payload topic:topic];
  
    }

static void on_subscribe(struct mosquitto *mosq, void *obj, int message_id, int qos_count, const int *granted_qos)
{
    MqttClient* client = (__bridge MqttClient*)obj;
    // FIXME: implement this
#ifdef trace_on
    NSLog(@"MQTTCLIENT: Subscribe");
#endif
    [[client delegate] didSubscribe:message_id grantedQos:nil];

}

static void on_unsubscribe(struct mosquitto *mosq, void *obj, int message_id)
{
    MqttClient* client = (__bridge MqttClient*)obj;
#ifdef trace_on
    NSLog(@"MQTTCLIENT: Unsubscribe");
#endif
    [[client delegate] didUnsubscribe:message_id];


}



// Initialize is called just before the first object is allocated
+ (void)initialize {
    mosquitto_lib_init();
    int major, minor, revision;
    mosquitto_lib_version(&major, &minor, &revision);
#ifdef trace_on
    NSLog(@"MQTTCLIENT: %@",[NSString stringWithFormat:@"%d.%d.%d", major, minor, revision]);
#endif
    
}

+ (NSString*)version {
    int major, minor, revision;
    mosquitto_lib_version(&major, &minor, &revision);
    return [NSString stringWithFormat:@"%d.%d.%d", major, minor, revision];
}

- (MqttClient*) initWithClientId:(NSString *)clientId {
    if ((self = [super init])) {
        const char* cstrClientId = [clientId cStringUsingEncoding:NSUTF8StringEncoding];
        [self setHost: hostString];
        
        
        [self setPort: 1883];
        //[self setPort: 8883];
       
       
        //Get the certificate from the bundle
        //Test if we are on a IPHONE or IPAD, use different cetificate
        
#ifdef trace_on
        NSLog(@"MQTT CLIENT: Openssl init");
#endif
        if (([[self platformNiceString] rangeOfString:@"iPhone"].location!=NSNotFound) || ([[self platformNiceString] rangeOfString:@"Simulator"].location!=NSNotFound) || ([[self platformNiceString] rangeOfString:@"MINI"].location!=NSNotFound))
            
        {
            caFile = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"crt"];
            clientFile = [[NSBundle mainBundle] pathForResource:@"iphone" ofType:@"crt"];
            clientKeyFile = [[NSBundle mainBundle] pathForResource:@"iphone" ofType:@"key"];
        }
        else
        {
            caFile = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"crt"];
            clientFile = [[NSBundle mainBundle] pathForResource:@"ipad" ofType:@"crt"];
            clientKeyFile = [[NSBundle mainBundle] pathForResource:@"ipad" ofType:@"key"];
        }
        
        
#ifdef trace_on
        NSLog(@"MQTT CLIENT: file for ca file %@",caFile);
        NSLog(@"MQTT CLIENT: file for client crt file %@",clientFile);
        NSLog(@"MQTT CLIENT: file for client key file %@",clientKeyFile);
#endif
        
        
    
        
        
        
        [self setKeepAlive: 5];
        [self setCleanSession: YES]; //NOTE: this isdisable clean to keep the broker remember this client
        
        mosq = mosquitto_new(cstrClientId, cleanSession, (__bridge void *)(self));
        mosquitto_connect_callback_set(mosq, on_connect);
        mosquitto_disconnect_callback_set(mosq, on_disconnect);
        mosquitto_publish_callback_set(mosq, on_publish);
        mosquitto_message_callback_set(mosq, on_message);
        mosquitto_subscribe_callback_set(mosq, on_subscribe);
        mosquitto_unsubscribe_callback_set(mosq, on_unsubscribe);
        
        timer = nil;
    }

    return self;
}


#pragma mark public_functions
- (int) connect {
    const char *cstrHost = [host cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cstrUsername = NULL, *cstrPassword = NULL;
    int isConnected=1;
    
    if (username)
        cstrUsername = [username cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (password)
        cstrPassword = [password cStringUsingEncoding:NSUTF8StringEncoding];
    
    // FIXME: check for errors
    mosquitto_username_pw_set(mosq, cstrUsername, cstrPassword);

    

    
    
    
//Enable this for using a secure connection
   if (port==8883)
    mosquitto_tls_set(mosq, [caFile UTF8String], NULL, [clientFile UTF8String], [clientKeyFile UTF8String], NULL);
    else
        mosquitto_tls_clear(mosq);
    
    isConnected = mosquitto_connect(mosq, cstrHost, port, keepAlive);
    
    // Setup timer to handle network events
    // FIXME: better way to do this - hook into iOS Run Loop select() ?
    // or run in seperate thread?
#ifdef trace_on
    NSLog(@"MQTTCLIENT: isConnected =%d",isConnected);
#endif
    timer = [NSTimer scheduledTimerWithTimeInterval:0.005 // 5ms
                                             target:self
                                           selector:@selector(loop:)
                                           userInfo:nil
                                            repeats:YES];
    return isConnected;
}

- (int) connectToHost: (NSString*)aHost {
    [self setHost:aHost];
    return [self connect];
}

- (void) reconnect {
    mosquitto_reconnect(mosq);
}

- (void) disconnect {
    mosquitto_disconnect(mosq);
}

- (void)subscribe: (NSString *)topic {
  
#ifdef trace_on
    NSLog(@"MQTTCLIENT: Subscribe to %@",topic);
#endif
    [self subscribe:topic withQos:0];
}

- (void)subscribe: (NSString *)topic withQos:(NSUInteger)qos {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_subscribe(mosq, NULL, cstrTopic, qos);
}

- (void)unsubscribe: (NSString *)topic {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_unsubscribe(mosq, NULL, cstrTopic);
}

- (void)setWill: (NSString *)payload toTopic:(NSString *)willTopic withQos:(NSUInteger)willQos retain:(BOOL)retain;
{
    const char* cstrTopic = [willTopic cStringUsingEncoding:NSUTF8StringEncoding];
    const uint8_t* cstrPayload = (const uint8_t*)[payload cStringUsingEncoding:NSUTF8StringEncoding];
    size_t cstrlen = [payload lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    mosquitto_will_set(mosq, cstrTopic, cstrlen, cstrPayload, willQos, retain);
}

- (void)clearWill
{
    mosquitto_will_clear(mosq);
}

- (void)publishString: (NSString *)payload toTopic:(NSString *)topic withQos:(NSUInteger)qos retain:(BOOL)retain {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    const uint8_t* cstrPayload = (const uint8_t*)[payload cStringUsingEncoding:NSUTF8StringEncoding];
    size_t cstrlen = [payload lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    mosquitto_publish(mosq, NULL, cstrTopic, cstrlen, cstrPayload, qos, retain);
    
}

- (void) setMessageRetry: (NSUInteger)seconds
{
    mosquitto_message_retry_set(mosq, (unsigned int)seconds);
}


- (void) loop: (NSTimer *)timer {
    mosquitto_loop(mosq, 1, 1);
}
@end
