#pragma once

namespace Skrapp {

struct App {
  static App *Make(int argc, char **argv);

  virtual ~App(){};

  virtual void onIdle() = 0;
};

} // namespace Skrapp
