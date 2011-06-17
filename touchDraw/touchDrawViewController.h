//
//  touchDrawViewController.h
//  touchDraw
//
//  Created by Rob Seward on 6/13/11.
//  Copyright 2011 VHS Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

#define kBeganType @"b"
#define kMovedType @"m"
#define kEndedType @"e"

@interface touchDrawViewController : UIViewController {
    GCDAsyncSocket *asyncSocket;
    }

- (void)normalConnect;
-(void) writeCoordinate:(NSString *)type point:(CGPoint)p;
- (IBAction)resetConnection:(id)sender;

@end
