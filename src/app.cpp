#include "fmt/format.h"

#include "skrapp/skrapp.h"
#include "skrapp/window.h"

#include "skia/core/SkCanvas.h"
#include "skia/core/SkGraphics.h"

struct Skrew : Skrapp::App
{
  Skrew(int argc, char **argv);
  ~Skrew() override;

  void render(SkSurface *surface) override;
};

Skrapp::App *Skrapp::App::Make(int argc, char **argv)
{
  return new Skrew(argc, argv);
}

Skrew::Skrew(int argc, char **argv)
    : App()
{
  fmt::print("ALIVE\n");
}

Skrew::~Skrew() {}

void Skrew::render(SkSurface *surface)
{
  fmt::print("Skrew render\n");
  SkCanvas *canvas = surface->getCanvas();
  canvas->clear(SK_ColorWHITE);
  SkPaint paint;
  paint.setColor(SK_ColorRED);
  SkRect redRect = SkRect::MakeXYWH(10, 10, 128, 128);
  canvas->drawRect(redRect, paint);
}
