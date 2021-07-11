#include "fmt/format.h"
#include "skia/core/SkGraphics.h"
#include "skrapp/skrapp.h"
#include "skrapp/window.h"

#include <memory>

struct Skrew : Skrapp::App
{
  std::unique_ptr<Skrapp::Window> window_;

  Skrew(int argc, char **argv);
  ~Skrew() override;

  void onIdle() override;
};

Skrapp::App *Skrapp::App::Make(int argc, char **argv)
{
  return new Skrew(argc, argv);
}

Skrew::Skrew(int argc, char **argv)
{
  SkGraphics::Init();

  window_ = Skrapp::Window::Make();

  fmt::print("ALIVE\n");
}

Skrew::~Skrew() {}

void Skrew::onIdle() {}
