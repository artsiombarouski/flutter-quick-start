#import "FlutterQuickStartPlugin.h"
#if __has_include(<flutter_quick_start/flutter_quick_start-Swift.h>)
#import <flutter_quick_start/flutter_quick_start-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_quick_start-Swift.h"
#endif

@implementation FlutterQuickStartPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterQuickStartPlugin registerWithRegistrar:registrar];
}
@end
