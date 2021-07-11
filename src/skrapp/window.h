#pragma once

#include <memory>

namespace Skrapp {

struct Window
{
  static std::unique_ptr<Window> Make();

  virtual ~Window();
};

} // namespace Skrapp
