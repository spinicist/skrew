#include "fmt/format.h"

#include "skrapp/skrapp.h"
#include "skrapp/window.h"

#include "skia/core/SkCanvas.h"
#include "skia/core/SkGraphics.h"

struct Skrew : Skrapp::App
{
  Skrew(int argc, char **argv);
  ~Skrew() override;

  void render(SkCanvas *const surface) override;
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

void Skrew::render(SkCanvas *const canvas)
{
  fmt::print("Skrew render\n");
  canvas->clear(SK_ColorWHITE);
  SkPaint paint;
  paint.setColor(SK_ColorRED);
  SkSize winSz = window()->size();
  SkRect redRect = SkRect::MakeXYWH(winSz.width() / 2, winSz.height() / 2, 128, 128);
  canvas->drawRect(redRect, paint);
}
