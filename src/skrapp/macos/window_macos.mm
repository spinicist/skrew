#include "window_macos.h"

#include "fmt/format.h"

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
- (SkSurface *)surface;
- (void)finishFrame;
@end

using Skrapp::Window;
using Skrapp::WindowMac;

std::unique_ptr<Window> Window::Make()
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  auto window = std::make_unique<WindowMac>();
  return window;
}

WindowMac::WindowMac()
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
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

  view_ = [[MainView alloc] initWithWindow:this];
  [window_ setContentView:view_];
  [window_ makeFirstResponder:view_];
  [window_ setDelegate:delegate];
  [window_ setAcceptsMouseMovedEvents:YES];
  [window_ setRestorable:NO];

  [window_ orderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
  [window_ makeKeyAndOrderFront:NSApp];
}

SkSurface *WindowMac::surface()
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  return [view_ surface];
}

void WindowMac::finishFrame()
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  [view_ finishFrame];
}

@implementation WindowDelegate {
  Skrapp::WindowMac *window_;
}

- (WindowDelegate *)initWithWindow:(Skrapp::WindowMac *)w
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  window_ = w;
  return self;
}

- (void)windowDidResize:(NSNotification *)notification
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
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
  sk_sp<SkSurface> surface_;
}

- (MainView *)initWithWindow:(Skrapp::WindowMac *)w
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
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

- (SkSurface *)surface
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  SkSurfaceProps surfaceProps(0, kRGB_H_SkPixelGeometry);
  id<CAMetalDrawable> currentDrawable = [layer_ nextDrawable];

  GrMtlTextureInfo fbInfo;
  fbInfo.fTexture.retain(currentDrawable.texture);

  GrBackendRenderTarget backendRT(640, 480, 1, fbInfo);

  surface_ = SkSurface::MakeFromBackendRenderTarget(
      context_.get(),
      backendRT,
      kTopLeft_GrSurfaceOrigin,
      kBGRA_8888_SkColorType,
      nullptr,
      &surfaceProps);

  drawable_ = CFRetain((GrMTLHandle)currentDrawable);
  return surface_.get();
}

- (void)finishFrame
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  surface_->flushAndSubmit();
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