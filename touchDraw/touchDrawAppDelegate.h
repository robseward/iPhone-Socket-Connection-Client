//
//  touchDrawAppDelegate.h
//  touchDraw
//
//  Created by Rob Seward on 6/13/11.
//  Copyright 2011 VHS Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class touchDrawViewController;

@interface touchDrawAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet touchDrawViewController *viewController;

@end
