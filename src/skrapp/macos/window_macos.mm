#include "window_macos.h"

#include "fmt/format.h"

#include "skia/core/SkCanvas.h"
#include "skia/core/SkGraphics.h"
#include "skia/core/SkSurface.h"
#include "skia/core/SkSurfaceProps.h"
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
}

@implementation WindowDelegate {
  Skrapp::WindowMac *window_;
}

- (WindowDelegate *)initWithWindow:(Skrapp::WindowMac *)w
{
  window_ = w;
  return self;
}

- (void)windowDidResize:(NSNotification *)notification
{
  fmt::print("WindowDelegate windowDidResize\n");
  // NSView *view = window_->window.contentView;
  // CGFloat scale = 1.f;
  // window_->onResize(view.bounds.size.width * scale, view.bounds.size.height * scale);
  // window_->render();
}

@end

@implementation MainView {
  Skrapp::WindowMac *window_;
  CAMetalLayer *layer_;
  GrMTLHandle drawable_;
  sk_cfp<id<MTLDevice>> device_;
  sk_cfp<id<MTLCommandQueue>> queue_;
  sk_sp<GrDirectContext> context_;
}

- (MainView *)initWithWindow:(Skrapp::WindowMac *)w
{
  fmt::print("MainView initWithWindow\n");
  self = [super init];
  window_ = w;

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
  NSColorSpace *cs = self.window.colorSpace;
  layer_.colorspace = cs.CGColorSpace;
  self.layer = layer_;
  self.wantsLayer = YES;

  return self;
}

- (void)drawRect:(NSRect)rect
{
  fmt::print("MainWindow drawRect\n");
  SkSurfaceProps surfaceProps(0, kRGB_H_SkPixelGeometry);
  sk_sp<SkSurface> surface = SkSurface::MakeFromCAMetalLayer(
      context_.get(),
      (__bridge GrMTLHandle)layer_,
      kTopLeft_GrSurfaceOrigin,
      1,
      kBGRA_8888_SkColorType,
      nullptr,
      &surfaceProps,
      &drawable_);

  auto canvas = surface->getCanvas();
  canvas->clear(SK_ColorWHITE);
  SkPaint paint;
  paint.setColor(SK_ColorRED);
  SkRect redRect = SkRect::MakeXYWH(10, 10, 128, 128);
  canvas->drawRect(redRect, paint);
  surface->flushAndSubmit();

  // Swap buffers
  id<CAMetalDrawable> currentDrawable = (id<CAMetalDrawable>)drawable_;
  id<MTLCommandBuffer> commandBuffer([*queue_ commandBuffer]);
  commandBuffer.label = @"Swap";
  [commandBuffer presentDrawable:currentDrawable];
  [commandBuffer commit];
  CFRelease(drawable_);
  drawable_ = nil;
}
@end