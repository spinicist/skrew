#pragma once

#include <memory>

#include "skia/core/SkSurface.h"

namespace Skrapp {

struct App;

struct Window
{
  static std::unique_ptr<Window> Make(App *);
  Window(App *app);
  virtual ~Window() = default;

  App *const app();
  virtual SkCanvas *const begin() = 0;
  virtual void finish() = 0;
  virtual SkSize size() = 0;
  virtual void resize() = 0;

private:
  App *app_;
};

} // namespace Skrapp
