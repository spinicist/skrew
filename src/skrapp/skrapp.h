#pragma once

#include "window.h"

namespace Skrapp {

struct App
{
  static App *Make(int argc, char **argv);

  App();
  virtual ~App(){};

  Window *window();
  virtual void layout(SkRect const rect) = 0;
  virtual void render(SkCanvas *const canvas) = 0;

private:
  std::unique_ptr<Skrapp::Window> window_;
};

} // namespace Skrapp
