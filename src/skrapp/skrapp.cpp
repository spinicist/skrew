#include "skrapp.h"

#include "fmt/format.h"
#include "skia/core/SkGraphics.h"

namespace Skrapp {

App::App()
    : dirty_{true}
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  SkGraphics::Init();
  window_ = Skrapp::Window::Make(this);
}

Window *App::window()
{
  return window_.get();
}

void App::setDirty()
{
  dirty_ = true;
}

void App::setClean()
{
  dirty_ = false;
}

bool App::isDirty()
{
  return dirty_;
}

} // namespace Skrapp
