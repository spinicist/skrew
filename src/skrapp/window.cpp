#include "window.h"

namespace Skrapp {

Window::Window(App *app)
    : app_{app}
{
}

App *const Window::app()
{
  return app_;
}

} // namespace Skrapp
