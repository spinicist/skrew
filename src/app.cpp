#include "fmt/format.h"

#include "skrapp/skrapp.h"
#include "skrapp/window.h"

#include "skia/core/SkCanvas.h"
#include "skia/core/SkGraphics.h"

struct Skrew : Skrapp::App
{
  Skrew(int argc, char **argv);
  ~Skrew() override;

  void layout(SkRect const rect) override;
  void render(SkCanvas *const surface) override;

  SkRect redRect_;
};

Skrapp::App *Skrapp::App::Make(int argc, char **argv)
{
  return new Skrew(argc, argv);
}

Skrew::Skrew(int argc, char **argv)
    : App()
{
  fmt::print("{}\n", __PRETTY_FUNCTION__);
}

Skrew::~Skrew() {}

void Skrew::layout(SkRect const rect)
{
  redRect_ = rect.makeInset(32, 32);
}

void Skrew::render(SkCanvas *const canvas)
{
  fmt::print("Skrew render\n");
  canvas->clear(SK_ColorWHITE);
  SkPaint paint;
  paint.setColor(SK_ColorRED);
  canvas->drawRect(redRect_, paint);
}
