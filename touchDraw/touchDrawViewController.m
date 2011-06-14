//
//  touchDrawViewController.m
//  touchDraw
//
//  Created by Rob Seward on 6/13/11.
//  Copyright 2011 VHS Design LLC. All rights reserved.
//

#import "touchDrawViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"


// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation touchDrawViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"HELLO?");
    DDLogInfo(@"HELLO AGAIN");
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
	
	asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
	
	[self normalConnect];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)normalConnect
{
	NSError *error = nil;
    
	NSString *host = @"192.168.1.103";
    //	NSString *host = @"google.com";
    //	NSString *host = @"deusty.com";
	
	if (![asyncSocket connectToHost:host onPort:6780 error:&error])
	{
		DDLogInfo(@"Error connecting: %@", error);
	}
    
	// You can also specify an optional connect timeout.
	
    //	if (![asyncSocket connectToHost:host onPort:80 withTimeout:5.0 error:&error])
    //	{
    //		DDLogError(@"Error connecting: %@", error);
    //	}
}

- (IBAction)resetConnection:(id)sender{
    if ([asyncSocket isConnected]) {
        [asyncSocket disconnect];
    }
    [self normalConnect];
}

//define the targetmethod
-(void) writeRandomData:(NSTimer *)theTimer {
    int random = (int)(arc4random() % 100);
    NSString* str= [NSString stringWithFormat:@"%d", random];
    NSData* data=[str dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:data withTimeout:10.0f tag:0];
    DDLogInfo(str);
}

-(void) writeCoordinate:(NSString *)type point:(CGPoint)p{
    NSString* str= [NSString stringWithFormat:@":%@,%d,%d:", type, (int)p.x, (int)p.y];
    NSData* data=[str dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:data withTimeout:10.0f tag:0];
    DDLogInfo(str);
}

- (void) timerWriteData:(NSTimer *)theTimer{
    if(touching){
        NSString* str= [NSString stringWithFormat:@":%@,%d,%d:", touchType, (int)touchPosition.x, (int)touchPosition.y];
        NSData* data=[str dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:data withTimeout:10.0f tag:0];
        DDLogInfo(str);
    }
    touching = NO;
    
}


#pragma mark - socket

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	DDLogInfo(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	
    //	DDLogInfo(@"localHost :%@ port:%hu", [sock localHost], [sock localPort]);
	
	if (port == 443)
	{
		
#if !TARGET_IPHONE_SIMULATOR
		
		// Backgrounding doesn't seem to be supported on the simulator yet
		
		[sock performBlock:^{
			if ([sock enableBackgroundingOnSocketWithCaveat])
				DDLogInfo(@"Enabled backgrounding on socket");
			else
				DDLogWarn(@"Enabling backgrounding failed!");
		}];
		
#endif
		
		// Configure SSL/TLS settings
		NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
		
		// If you simply want to ensure that the remote host's certificate is valid,
		// then you can use an empty dictionary.
		
		// If you know the name of the remote host, then you should specify the name here.
		// 
		// NOTE:
		// You should understand the security implications if you do not specify the peer name.
		// Please see the documentation for the startTLS method in GCDAsyncSocket.h for a full discussion.
		
		[settings setObject:@"www.paypal.com"
					 forKey:(NSString *)kCFStreamSSLPeerName];
		
		// To connect to a test server, with a self-signed certificate, use settings similar to this:
		
        //	// Allow expired certificates
        //	[settings setObject:[NSNumber numberWithBool:YES]
        //				 forKey:(NSString *)kCFStreamSSLAllowsExpiredCertificates];
        //	
        //	// Allow self-signed certificates
        //	[settings setObject:[NSNumber numberWithBool:YES]
        //				 forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
        //	
        //	// In fact, don't even validate the certificate chain
        //	[settings setObject:[NSNumber numberWithBool:NO]
        //				 forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
		
		DDLogVerbose(@"Starting TLS with settings:\n%@", settings);
		
		[sock startTLS:settings];
		
		// You can also pass nil to the startTLS method, which is the same as passing an empty dictionary.
		// Again, you should understand the security implications of doing so.
		// Please see the documentation for the startTLS method in GCDAsyncSocket.h for a full discussion.
        
	}
    
    //[NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerWriteData:) userInfo:nil repeats:YES];
    
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
	DDLogInfo(@"socketDidSecure:%p", sock);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	DDLogInfo(@"socketDidDisconnect:%p withError: %@", sock, err);
}

#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    touchType = @"b";
    touchPosition = [[touches anyObject] locationInView:self.view];
    touching = YES;
    [self timerWriteData:nil];
    //[self writeCoordinate:@"b" point:pt];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    touchType = @"m";
    touchPosition = [[touches anyObject] locationInView:self.view];
    touching = YES;
    [self timerWriteData:nil];

    //[self writeCoordinate:@"m" point:pt];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    touchType = @"e";
    touchPosition = [[touches anyObject] locationInView:self.view];
    touching = YES;
    [self timerWriteData:nil];

    //[self writeCoordinate:@"e" point:pt];
}

@end
