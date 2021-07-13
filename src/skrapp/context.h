#pragma once

#include "skia/core/SkImageInfo.h"
#include "skia/core/SkRefCnt.h"
#include "skia/core/SkSurfaceProps.h"
#include "skia/gpu/GrContext.h"
#include "skia/gpu/GrContextOptions.h"
#include "skia/gpu/GrTypes.h"

class SkSurface;
class GrRenderTarget;

namespace Skrapp {

struct DisplayParams
{
  DisplayParams()
      : fColorType(kN32_SkColorType)
      , fColorSpace(nullptr)
      , fMSAASampleCount(1)
      , fSurfaceProps(SkSurfaceProps::kLegacyFontHost_InitType)
      , fDisableVsync(false)
  {
  }

  SkColorType fColorType;
  sk_sp<SkColorSpace> fColorSpace;
  int fMSAASampleCount;
  GrContextOptions fGrContextOptions;
  SkSurfaceProps fSurfaceProps;
  bool fDisableVsync;
};

struct Context
{

  Context(const DisplayParams &params)
      : fContext(nullptr)
      , fDisplayParams(params)
      , fSampleCount(1)
      , fStencilBits(0)
  {
  }

  virtual ~WindowContext() {}

  virtual sk_sp<SkSurface> getBackbufferSurface() = 0;

  virtual void swapBuffers() = 0;

  virtual bool isValid() = 0;

  virtual void resize(int w, int h) = 0;

  const DisplayParams &getDisplayParams()
  {
    return fDisplayParams;
  }
  virtual void setDisplayParams(const DisplayParams &params) = 0;

  GrContext *getGrContext() const
  {
    return fContext.get();
  }

  int width() const
  {
    return fWidth;
  }
  int height() const
  {
    return fHeight;
  }
  int sampleCount() const
  {
    return fSampleCount;
  }
  int stencilBits() const
  {
    return fStencilBits;
  }

protected:
  virtual bool isGpuContext()
  {
    return true;
  }

  sk_sp<GrContext> fContext;

  int fWidth;
  int fHeight;
  DisplayParams fDisplayParams;

  // parameters obtained from the native window
  // Note that the platform .cpp file is responsible for
  // initializing fSampleCount and fStencilBits!
  int fSampleCount;
  int fStencilBits;
};

} // namespace Skrapp

#endif
