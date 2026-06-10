#if SWIFT_PACKAGE
import Flutter

@objc(LocalAuthSignaturePlugin)
public final class LocalAuthSignaturePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftLocalAuthSignaturePlugin.register(with: registrar)
    }
}
#endif
