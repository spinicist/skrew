#pragma once

#include "../window.h"

#import <Cocoa/Cocoa.h>

@class MainView;

namespace Skrapp {

struct WindowMac : public Window
{
  WindowMac();
  ~WindowMac() override {}

  SkSurface *const begin() override;
  void finish() override;

private:
  NSWindow *window_;
  MainView *view_;
};

} // namespace Skrapp
