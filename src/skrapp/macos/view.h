#pragma once

#import <Cocoa/Cocoa.h>

#include "skia/core/SkSurface.h"

namespace Skrapp {
struct WindowMac;
}

@interface MainView : NSView
- (MainView *)initWithWindow:(Skrapp::WindowMac *)initWindow;
- (SkSurface *const)begin;
- (void)finish;
- (void)resize;
@end
