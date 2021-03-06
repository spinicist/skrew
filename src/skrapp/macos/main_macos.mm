/*
 *
 */

#import <Cocoa/Cocoa.h>

#include "../skrapp.h"
#include "fmt/format.h"

class SkSurface;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property(nonatomic, assign) BOOL done;

@end

@implementation AppDelegate : NSObject

@synthesize done = _done;

- (id)init
{
  self = [super init];
  _done = FALSE;
  return self;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
  _done = TRUE;
  return NSTerminateCancel;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  [NSApp stop:nil];
}

@end

int main(int argc, char *argv[])
{
#if MAC_OS_X_VERSION_MAX_ALLOWED < 1070
  // we only run on systems that support at least Core Profile 3.2
  return EXIT_FAILURE;
#endif

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [NSApplication sharedApplication];

  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

  // Create the application menu.
  NSMenu *menuBar = [[NSMenu alloc] initWithTitle:@"SkrApp"];
  [NSApp setMainMenu:menuBar];

  NSMenuItem *item;
  NSMenu *subMenu;

  item = [[NSMenuItem alloc] initWithTitle:@"Apple" action:NULL keyEquivalent:@""];
  [menuBar addItem:item];
  subMenu = [[NSMenu alloc] initWithTitle:@"Apple"];
  [menuBar setSubmenu:subMenu forItem:item];
  [item release];
  item = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
  [subMenu addItem:item];
  [item release];
  [subMenu release];

  // Set AppDelegate to catch certain global events
  AppDelegate *appDelegate = [[AppDelegate alloc] init];
  [NSApp setDelegate:appDelegate];

  Skrapp::App *app = Skrapp::App::Make(argc, argv);
  app->window()->resize(); // This needs to go here because within the constructor above dynamic
                           // dispatch does not work
  // This will run until the application finishes launching, then lets us take
  // over
  [NSApp run];

  // Now we process the events
  while (![appDelegate done]) {
    fmt::print("Received event\n");
    NSEvent *event;
    do {
      event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                 untilDate:[NSDate distantPast]
                                    inMode:NSDefaultRunLoopMode
                                   dequeue:YES];
      fmt::print("{}\n", event.type);
      [NSApp sendEvent:event];
    } while (event != nil);

    [pool drain];
    pool = [[NSAutoreleasePool alloc] init];

    if (app->isDirty()) {
      app->render(app->window()->begin());
      app->window()->finish();
    }
    event = [NSApp nextEventMatchingMask:NSEventMaskAny
                               untilDate:[NSDate distantFuture]
                                  inMode:NSDefaultRunLoopMode
                                 dequeue:NO];
  }

  // delete app;

  [NSApp setDelegate:nil];
  [appDelegate release];

  [menuBar release];
  [pool release];

  return EXIT_SUCCESS;
}
