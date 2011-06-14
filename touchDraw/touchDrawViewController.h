//
//  touchDrawViewController.h
//  touchDraw
//
//  Created by Rob Seward on 6/13/11.
//  Copyright 2011 VHS Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface touchDrawViewController : UIViewController {
    GCDAsyncSocket *asyncSocket;
}

- (void)normalConnect;


@end
