#pragma once

#import <Cocoa/Cocoa.h>

#include "window_macos.h"

@interface WindowDelegate : NSObject <NSWindowDelegate>
- (WindowDelegate *)initWithWindow:(Skrapp::WindowMac *)initWindow;
@end
