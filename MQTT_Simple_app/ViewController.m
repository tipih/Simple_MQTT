//
//  ViewController.m
//  MQTT_Simple_app
//
//  Created by Michael Rahr on 23/04/14.
//  Copyright (c) 2014 Rahr. All rights reserved.
//

#import "ViewController.h"
#import "mqttDelegate.h"
#import "AppDelegate.h"

@interface ViewController ()<mqttDelegate>

@end

@implementation ViewController
bool isConnected;
@synthesize broakerIp;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    isConnected=false;
    //We need a ref. to our main app, to call subscribe in the common mqtt client
    //I do not really know it this approche is a good one. But it works
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    //Now we need a ref to the mqtt client
    MqttClient *mosq = [app mqttclient];
    //Before anything else we need to tell the mqtt cleint who should be the delegate e.g. receiving the info from the client
    [mosq setDelegate:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)connectToBroaker:(id)sender {
    
    NSLog(@"Try to connect to MQTT broaker");
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    //Now we need a ref to the mqtt client
    MqttClient *mosq = [app mqttclient];
    
    isConnected =[mosq connectToHost:@"127.0.0.1"];
    
    
}





//***********************************************************************************************
#pragma mark MQTT callback

//MAIN Call back from mqtt services
- (void)didReceiveMessage:(MqttMessage *)mosq_msg{
    //NSLog(@"%@",mosq_msg.payload);
    //NSLog(@"%@",[Model getSomeData]);
    
    NSString *messageTropic  =   [mosq_msg topic];
    NSString *messageData    =   [mosq_msg payload];
    //Split the topic string, so that we only need to branch out on a serviceavailable message
    NSArray *subString = [messageTropic componentsSeparatedByString:@"/"] ;
    NSLog(@"CONTAINER CONTROLLER: Got a systemservice of %@",messageTropic);

}

- (void)didPublish:(NSUInteger)messageId{
    NSLog(@"Message id =%d",messageId);
}

- (void)didSubscribe:(NSUInteger)messageId grantedQos:(NSArray *)qos{
    NSLog(@"Did subscribe to %d",messageId);
}


- (void)didConnect:(NSUInteger)code ipAddr:(NSString *)IPAddrString
{
    NSLog(@"CONTAINER CONTROLLER: got a connect from callback, disabling the service browser");
    //We manage to connect to a server, now lets us try to subscribe to something
    
    //We need a ref. to our main app, to call subscribe in the common mqtt client
    //I do not really know it this approche is a good one. But it works
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    //Now we need a ref to the mqtt client
    MqttClient *mosq = [app mqttclient];
    
    //Subscribe to the commandavailable and dataavailable main services
    //with wildcard this will give us all data and command available in the system
    //we will receive all data in the callback function, we
    
    
    //Update the UI
    broakerIp.text=[NSString stringWithFormat:@"Broaker @ %@", IPAddrString];
    isConnected=true;
    
}


- (void)didUnsubscribe:(NSUInteger)messageId{
    
}

- (void)didDisconnect{
    broakerIp.text=@"Disconnected from Broaker";
    isConnected=false;
   

}






@end
