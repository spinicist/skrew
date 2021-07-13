#pragma once

#include "../window.h"

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

#include "skia/gpu/GrDirectContext.h"
#include "skia/gpu/mtl/GrMtlTypes.h"

namespace Skrapp {

struct WindowMac : public Window
{
  WindowMac();
  ~WindowMac() override {}

private:
  NSWindow *window_;
  CAMetalLayer *layer_;
  sk_cfp<id<MTLDevice>> device_;
  sk_cfp<id<MTLCommandQueue>> queue_;
  sk_sp<GrDirectContext> context_;
};

} // namespace Skrapp
