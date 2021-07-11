#pragma once

#include "../window.h"

#import <Cocoa/Cocoa.h>

namespace Skrapp {

struct WindowMac : public Window
{
  WindowMac();
  ~WindowMac() override {}

private:
  NSWindow *window_;
};

} // namespace Skrapp
