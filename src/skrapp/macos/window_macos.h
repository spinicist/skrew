#pragma once

#include "../window.h"

#import <Cocoa/Cocoa.h>

@class MainView;

namespace Skrapp {

struct WindowMac : public Window
{
  WindowMac(App *app);
  ~WindowMac() override {}

  SkCanvas *const begin() override;
  void finish() override;
  SkSize size() override;
  void resize() override;

private:
  NSWindow *window_;
  MainView *view_;
};

} // namespace Skrapp
