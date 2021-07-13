#include "skrapp.h"

#include "skia/core/SkGraphics.h"

namespace Skrapp {

App::App()
{
  SkGraphics::Init();
  window_ = Skrapp::Window::Make();
}

Window *App::window()
{
  return window_.get();
}

} // namespace Skrapp
