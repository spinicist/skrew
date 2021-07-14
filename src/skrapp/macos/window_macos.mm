#include "window_macos.h"

#include "fmt/format.h"

#include "../skrapp.h"
#include "view.h"
#include "window_delegate.h"

using Skrapp::Window;
using Skrapp::WindowMac;

std::unique_ptr<Window> Window::Make(App *app)
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  auto window = std::make_unique<WindowMac>(app);
  return window;
}

WindowMac::WindowMac(App *app)
    : Window{app}
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  WindowDelegate *delegate = [[WindowDelegate alloc] initWithWindow:this];

  constexpr int iw = 640;
  constexpr int ih = 480;
  NSRect windowRect = NSMakeRect(100, 100, iw, ih);
  NSUInteger windowStyle =
      (NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable |
       NSWindowStyleMaskMiniaturizable);
  window_ = [[NSWindow alloc] initWithContentRect:windowRect
                                        styleMask:windowStyle
                                          backing:NSBackingStoreBuffered
                                            defer:NO];

  view_ = [[MainView alloc] initWithWindow:this];
  [window_ setContentView:view_];
  [window_ makeFirstResponder:view_];
  [window_ setDelegate:delegate];
  [window_ setAcceptsMouseMovedEvents:YES];
  [window_ setRestorable:NO];

  [window_ orderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
  [window_ makeKeyAndOrderFront:NSApp];
}

SkCanvas *const WindowMac::begin()
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  return [view_ begin];
}

void WindowMac::finish()
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  [view_ finish];
}

SkSize WindowMac::size()
{
  SkSize sz = SkSize::Make(view_.bounds.size.width, view_.bounds.size.height);
  return sz;
}

void WindowMac::resize()
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  [view_ resize];
  app()->layout(SkRect::MakeSize(size()));
}