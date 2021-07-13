#include "window_macos.h"

#include "skia/gpu/mtl/GrMtlBackendContext.h"
#include "skia/gpu/mtl/GrMtlTypes.h"

#import <QuartzCore/CAConstraintLayoutManager.h>

@interface WindowDelegate : NSObject <NSWindowDelegate>
- (WindowDelegate *)initWithWindow:(Skrapp::WindowMac *)initWindow;
@end

@interface MainView : NSView
- (MainView *)initWithWindow:(Skrapp::WindowMac *)initWindow;
@end

using Skrapp::Window;
using Skrapp::WindowMac;

std::unique_ptr<Window> Window::Make()
{
  auto window = std::make_unique<WindowMac>();
  return window;
}

WindowMac::WindowMac()
{
  WindowDelegate *delegate = [[WindowDelegate alloc] initWithWindow:this];

  constexpr int iw = 640;
  constexpr int ih = 480;
  NSRect windowRect = NSMakeRect(100, 100, iw, ih);
  NSUInteger windowStyle =
      (NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable |
       NSWindowStyleMaskMiniaturizable);
  window_ = [[NSWindow alloc] initWithContentRect:windowRect
                                        styleMask:windowStyle
                                          backing:NSBackingStoreBuffered
                                            defer:NO];

  MainView *view = [[MainView alloc] initWithWindow:this];
  [window_ setContentView:view];
  [window_ makeFirstResponder:view];
  [window_ setDelegate:delegate];
  [window_ setAcceptsMouseMovedEvents:YES];
  [window_ setRestorable:NO];

  [view release];

  [window_ orderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
  [window_ makeKeyAndOrderFront:NSApp];

  device_.reset(MTLCreateSystemDefaultDevice());
  queue_.reset([*device_ newCommandQueue]);

  GrMtlBackendContext back = {};
  back.fDevice.retain((GrMTLHandle)device_.get());
  back.fQueue.retain((GrMTLHandle)queue_.get());
  context_ = GrDirectContext::MakeMetal(back, GrContextOptions());

  layer_ = [CAMetalLayer layer];
  layer_.device = device_.get();
  layer_.pixelFormat = MTLPixelFormatBGRA8Unorm;
  layer_.layoutManager = [CAConstraintLayoutManager layoutManager];
  layer_.autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;
  layer_.contentsGravity = kCAGravityTopLeft;
  layer_.magnificationFilter = kCAFilterNearest;
  NSColorSpace *cs = view.window.colorSpace;
  layer_.colorspace = cs.CGColorSpace;
  view.layer = layer_;
  view.wantsLayer = YES;
}

@implementation WindowDelegate {
  Skrapp::WindowMac *window_;
}

- (WindowDelegate *)initWithWindow:(Skrapp::WindowMac *)w
{
  window_ = w;
  return self;
}

@end

@implementation MainView {
  Skrapp::WindowMac *window_;
}

- (MainView *)initWithWindow:(Skrapp::WindowMac *)w
{
  self = [super init];
  window_ = w;

  return self;
}

@end