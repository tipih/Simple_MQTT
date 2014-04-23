//
//  ServerBrowser.h
//  MQTT broaker searcher using bonjour
//


#import <Foundation/Foundation.h>
#import "ServerBrowserDelegate.h"



@interface ServerBrowser : NSObject <NSNetServiceBrowserDelegate,NSNetServiceDelegate>
{
  NSNetServiceBrowser* netServiceBrowser;
  NSMutableArray* servers;
//  id<ServerBrowserDelegate> delegate;
}
@property(atomic,readonly,strong) NSString* broakerIp;
@property(nonatomic,readonly) NSArray* servers;
@property(nonatomic,weak) id<ServerBrowserDelegate> delegate;

// Start browsing for Bonjour services
- (BOOL)start;

// Stop everything
- (void)stop;

@end
