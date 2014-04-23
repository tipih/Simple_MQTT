//
//  ServerBrowser.m
//  Bonjour search for MQTT broaker
//


//Container view will start the service discovery allready at starting up, if we get a connection to a
//broaker service will be stopped, if not, and if we find one, that will be used, and last good know host
//will be stored in a plist


#import "ServerBrowserDelegate.h"
#import "ServerBrowser.h"
#include <arpa/inet.h>
#define trace_on


// A category on NSNetService that's used to sort NSNetService objects by their name.
@interface NSNetService (BrowserViewControllerAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService*)aService;
@end

@implementation NSNetService (BrowserViewControllerAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService*)aService {
	return [[self name] localizedCaseInsensitiveCompare:[aService name]];
}
@end


// Private properties and methods
@interface ServerBrowser ()

// Sort services alphabetically
- (void)sortServers;

@end


@implementation ServerBrowser

@synthesize servers;
@synthesize broakerIp;
@synthesize delegate;

// Initialize
- (id)init {
    self = [super init];
    if (self) {
        servers = [[NSMutableArray alloc] init];
        broakerIp=nil;
    }
  return self;
}


// Cleanup


// Start browsing for servers
- (BOOL)start {
  
#ifdef trace_on
    NSLog(@"SERVER BROWSER: Starting to search");
#endif
    // Restarting?
  if ( netServiceBrowser != nil ) {
    [self stop];
  }

	netServiceBrowser = [[NSNetServiceBrowser alloc] init];
	if( !netServiceBrowser ) {
		return NO;
	}

	netServiceBrowser.delegate = self;
	[netServiceBrowser searchForServicesOfType:@"_mqtt._tcp." inDomain:@"local."];
  
  return YES;
}


// Terminate current service browser and clean up
- (void)stop {
  if ( netServiceBrowser == nil ) {
    return;
  }
  
  [netServiceBrowser stop];
  netServiceBrowser = nil;
  
  [servers removeAllObjects];
   // [delegate updateMQTTBroakerIp];
}


// Sort servers array by service names
- (void)sortServers {
  [servers sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
}


#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Method Implementations

// New service was found
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
  // Make sure that we don't have such service already (why would this happen? not sure)
  if ( ! [servers containsObject:netService] ) {
    // Add it to our list
      [netService setDelegate:self];
      [netService resolveWithTimeout:5.0];
      
           [servers addObject:netService];
#ifdef trace_on
      NSLog(@"SERVER BROWSER..............: %@",netService);
#endif
  }

  // If more entries are coming, no need to update UI just yet
  if ( moreServicesComing ) {
    return;
  }
  
  // Sort alphabetically and let our delegate know
  

  
  [self sortServers];
  //[delegate updateMQTTBroakerIp];
}


-(void)netServiceDidResolveAddress:(NSNetService *)netService{
    // Make sure [netService addresses] contains the
    // necessary connection information
#ifdef trace_on
    NSLog(@"SERVER BROWSER: got a netservice");
#endif
    if ([self addressesComplete:[netService addresses]
                 forServiceType:[netService type]]) {
#ifdef trace_on
        NSLog(@"SERVER BROWSER: manage to resolve host ip");
#endif
        [delegate updateMQTTBroakerIp];
    }
}



// Verifies [netService addresses]
- (BOOL)addressesComplete:(NSArray *)addresses

           forServiceType:(NSString *)serviceType
{
    
    // Perform appropriate logic to ensure that [netService addresses]
    // contains the appropriate information to connect to the service
    
    
    
    //NSData *myData = nil;
    
    
    //myData = [addresses objectAtIndex:0];
    
    for (NSData* myData in addresses){
    
    
    NSString *addressString;
    int port=0;
    struct sockaddr *addressGeneric;
   // struct sockaddr_in addressClient;
    
    
    addressGeneric = (struct sockaddr *) [myData bytes];
    #ifdef trace_on
        NSLog(@"SERVER BROWSER famely %hhu",addressGeneric->sa_family);
#endif
    switch( addressGeneric->sa_family ) {
        case AF_INET: {
            struct sockaddr_in *ip4;
            char dest[INET_ADDRSTRLEN];
            ip4 = (struct sockaddr_in *) [myData bytes];
            port = ntohs(ip4->sin_port);
            addressString = [NSString stringWithFormat: @"IP4: %s Port: %d", inet_ntop(AF_INET, &ip4->sin_addr, dest, sizeof dest),port];
            broakerIp=[NSString stringWithFormat:@"%s",inet_ntop(AF_INET, &ip4->sin_addr, dest, sizeof dest)];
#ifdef trace_on
            NSLog(@"SERVER BROWSER: Broaker IP %@",broakerIp);
#endif
        }
            break;
            
        case AF_INET6: {
            struct sockaddr_in6 *ip6;
            char dest[INET6_ADDRSTRLEN];
            ip6 = (struct sockaddr_in6 *) [myData bytes];
            port = ntohs(ip6->sin6_port);
            addressString = [NSString stringWithFormat: @"IP6: %s Port: %d",  inet_ntop(AF_INET6, &ip6->sin6_addr, dest, sizeof dest),port];
            //For test purpose we do not store IPV6 
            //broakerIp=[NSString stringWithFormat:@"%s",inet_ntop(AF_INET6, &ip6->sin6_addr, dest, sizeof dest)];
        }
            break;
        default:
            addressString=@"Unknown family";
            broakerIp=nil;
            return NO;
            break;
    }
#ifdef trace_on
    NSLog(@"Client Address: %@",addressString);
#endif
    }
    
    return YES;
}



// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
  // Remove from list
  [servers removeObject:netService];

  // If more entries are coming, no need to update UI just yet
  if ( moreServicesComing ) {
    return;
  }
  
  // Sort alphabetically and let our delegate know
  [self sortServers];
 // [delegate updateMQTTBroakerIp];
}

@end
