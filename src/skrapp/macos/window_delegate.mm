#include "window_delegate.h"

#include "fmt/format.h"

@implementation WindowDelegate {
  Skrapp::WindowMac *window_;
}

- (WindowDelegate *)initWithWindow:(Skrapp::WindowMac *)w
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  window_ = w;
  return self;
}

- (void)windowDidResize:(NSNotification *)notification
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
  // NSView *view = window_->window.contentView;
  // CGFloat scale = 1.f;
  // window_->onResize(view.bounds.size.width * scale, view.bounds.size.height * scale);
  // window_->render();
}

@end
