#pragma once

#include "../window.h"

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

#include "skia/gpu/GrDirectContext.h"
#include "skia/gpu/mtl/GrMtlTypes.h"

@class MainView;

namespace Skrapp {

struct WindowMac : public Window
{
  WindowMac();
  ~WindowMac() override {}

  SkSurface *surface() override;
  void finishFrame() override;

private:
  NSWindow *window_;
  MainView *view_;
};

} // namespace Skrapp
