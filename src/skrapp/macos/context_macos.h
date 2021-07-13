#pragma once

#include "../context.h"

#include <Cocoa/Cocoa.h>

namespace Skrapp {

struct ContextMac : Context
{
  ContextMac(NSView *mv);

  sk_sp<SkSurface> getBackbufferSurface() override;

  bool isValid() override
  {
    return fValid;
  }

  void swapBuffers() override;

  void setDisplayParams(const DisplayParams &params) override;

protected:
  void initializeContext();
  virtual bool onInitializeContext() = 0;

  // This should be called by subclass destructor. It is also called when window/display
  // parameters change prior to initializing a new Metal context. This will in turn call
  // onDestroyContext().
  void destroyContext();
  virtual void onDestroyContext() = 0;

  bool fValid;
  id<MTLDevice> fDevice;
  id<MTLCommandQueue> fQueue;
  CAMetalLayer *fMetalLayer;
  GrMTLHandle fDrawableHandle;
};

} // namespace Skrapp
