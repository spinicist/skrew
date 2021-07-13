#pragma once

#include <memory>

#include "skia/core/SkSurface.h"

namespace Skrapp {

struct Window
{
  static std::unique_ptr<Window> Make();
  virtual ~Window() = default;

  virtual SkSurface *surface() = 0;
  virtual void finishFrame() = 0;
};

} // namespace Skrapp
