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

#define kIpAddress @"192.168.1.103"
#define kPort 6780

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation touchDrawViewController

- (void)dealloc
{
    [super dealloc];
    [asyncSocket release];
}


#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    dispatch_queue_t mainQueue = dispatch_get_main_queue();	
	asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];	
	[self normalConnect];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)normalConnect
{
	NSError *error = nil;
    
	NSString *host = kIpAddress;

	
	if (![asyncSocket connectToHost:host onPort:kPort error:&error])
	{
		DDLogInfo(@"Error connecting: %@", error);
	}
}

- (IBAction)resetConnection:(id)sender{
    if ([asyncSocket isConnected]) {
        [asyncSocket disconnect];
    }
    [self normalConnect];
}



-(void) writeCoordinate:(NSString *)type point:(CGPoint)p{
    NSString* str= [NSString stringWithFormat:@":%@,%d,%d:", type, (int)p.x, (int)p.y];
    NSData* data=[str dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:data withTimeout:10.0f tag:0];
    DDLogInfo(str);
}



#pragma mark - socket

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	DDLogInfo(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
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
    NSString *touchType = @"b";
    CGPoint touchPosition = [[touches anyObject] locationInView:self.view];
    
    [self writeCoordinate:touchType point:touchPosition];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSString *touchType = @"m";
    CGPoint touchPosition = [[touches anyObject] locationInView:self.view];
    
    [self writeCoordinate:touchType point:touchPosition];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSString *touchType = @"e";
    CGPoint touchPosition = [[touches anyObject] locationInView:self.view];
   

    [self writeCoordinate:touchType point:touchPosition];
}

@end
