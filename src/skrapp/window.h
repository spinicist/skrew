#pragma once

#include <memory>

#include "skia/core/SkSurface.h"

namespace Skrapp {

struct Window
{
  static std::unique_ptr<Window> Make();
  virtual ~Window() = default;

  virtual SkCanvas *const begin() = 0;
  virtual void finish() = 0;
  virtual SkSize size() = 0;
  virtual void resize() = 0;
};

} // namespace Skrapp
