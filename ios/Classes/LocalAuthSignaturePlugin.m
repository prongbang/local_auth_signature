#import "LocalAuthSignaturePlugin.h"
#if __has_include(<local_auth_signature/local_auth_signature-Swift.h>)
#import <local_auth_signature/local_auth_signature-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "local_auth_signature-Swift.h"
#endif

@implementation LocalAuthSignaturePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLocalAuthSignaturePlugin registerWithRegistrar:registrar];
}
@end
