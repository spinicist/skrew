#include "view.h"

#import <Metal/Metal.h>
#import <QuartzCore/CAConstraintLayoutManager.h>
#import <QuartzCore/CAMetalLayer.h>

#include "skia/core/SkSurface.h"
#include "skia/core/SkSurfaceProps.h"
#include "skia/gpu/GrDirectContext.h"
#include "skia/gpu/mtl/GrMtlBackendContext.h"
#include "skia/gpu/mtl/GrMtlTypes.h"

#include "fmt/format.h"

@implementation MainView {
  Skrapp::WindowMac *window_;
  CAMetalLayer *layer_;
  GrMTLHandle drawable_;
  sk_cfp<id<MTLDevice>> device_;
  sk_cfp<id<MTLCommandQueue>> queue_;
  sk_sp<GrDirectContext> context_;
  sk_sp<SkSurface> surface_;
  int width_, height_;
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

- (SkSurface *const)begin
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  SkSurfaceProps surfaceProps(0, kRGB_H_SkPixelGeometry);
  id<CAMetalDrawable> currentDrawable = [layer_ nextDrawable];

  GrMtlTextureInfo fbInfo;
  fbInfo.fTexture.retain(currentDrawable.texture);
  GrBackendRenderTarget backendRT(width_, height_, 1, fbInfo);
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

- (void)finish
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

- (void)resize
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  float const scale = self.window.screen.backingScaleFactor;
  CGSize backingSize = self.bounds.size;
  backingSize.width *= scale;
  backingSize.height *= scale;

  layer_.drawableSize = backingSize;
  layer_.contentsScale = scale;

  width_ = backingSize.width;
  height_ = backingSize.height;
  fmt::print("w {} h {}\n", width_, height_);
}
@end
