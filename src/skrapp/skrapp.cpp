#include "skrapp.h"

#include "fmt/format.h"
#include "skia/core/SkGraphics.h"

namespace Skrapp {

App::App()
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  SkGraphics::Init();
  window_ = Skrapp::Window::Make(this);
}

Window *App::window()
{
  return window_.get();
}

} // namespace Skrapp
