import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'local_auth_signature_method_channel.dart';

abstract class LocalAuthSignaturePlatform extends PlatformInterface {
  /// Constructs a LocalAuthSignaturePlatform.
  LocalAuthSignaturePlatform() : super(token: _token);

  static final Object _token = Object();

  static LocalAuthSignaturePlatform _instance = MethodChannelLocalAuthSignature();

  /// The default instance of [LocalAuthSignaturePlatform] to use.
  ///
  /// Defaults to [MethodChannelLocalAuthSignature].
  static LocalAuthSignaturePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocalAuthSignaturePlatform] when
  /// they register themselves.
  static set instance(LocalAuthSignaturePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
