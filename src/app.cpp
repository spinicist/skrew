#include "fmt/format.h"
#include "skia/core/SkGraphics.h"
#include "skrapp/skrapp.h"

struct Sommelier : Skrapp::App
{
  Sommelier(int argc, char **argv);
  ~Sommelier() override;

  void onIdle() override;
};

Skrapp::App *Skrapp::App::Make(int argc, char **argv)
{
  return new Sommelier(argc, argv);
}

Sommelier::Sommelier(int argc, char **argv)
{
  SkGraphics::Init();
  fmt::print("ALIVE\n");
}

Sommelier::~Sommelier() {}

void Sommelier::onIdle() {}
