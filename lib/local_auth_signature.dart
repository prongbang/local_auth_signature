import 'package:local_auth_signature/local_auth_signature_method_channel.dart';
import 'package:local_auth_signature/src/android_prompt_info.dart';
import 'package:local_auth_signature/src/ios_prompt_info.dart';
import 'package:local_auth_signature/src/key_changed_status.dart';

export 'src/android_prompt_info.dart';
export 'src/ios_prompt_info.dart';
export 'src/local_auth_signature_error.dart';
export 'src/key_changed_status.dart';

abstract class LocalAuthSignature {
  LocalAuthSignature() : super();

  static LocalAuthSignature _instance = MethodChannelLocalAuthSignature();

  /// The default instance of [LocalAuthSignature] to use.
  ///
  /// Defaults to [MethodChannelLocalAuthSignature].
  static LocalAuthSignature get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocalAuthSignature] when
  /// they register themselves.
  static set instance(LocalAuthSignature instance) {
    _instance = instance;
  }

  Future<KeyChangedStatus?> isBiometricChanged(String key) {
    throw UnimplementedError('isBiometricChanged() has not been implemented.');
  }

  /// Supported for iOS only, do nothing when run on Android and return false always.
  Future<bool> resetBiometricChanged() {
    throw UnimplementedError(
        'resetBiometricChanged() has not been implemented.');
  }

  Future<String?> createKeyPair(
    String key,
    AndroidPromptInfo androidPromptInfo,
    IOSPromptInfo iosPromptInfo,
  ) {
    throw UnimplementedError('createKeyPair() has not been implemented.');
  }

  Future<String?> sign(
    String key,
    String payload,
    AndroidPromptInfo androidPromptInfo,
    IOSPromptInfo iosPromptInfo,
  ) {
    throw UnimplementedError('sign() has not been implemented.');
  }

  Future<bool> verify(
    String key,
    String payload,
    String signature,
    AndroidPromptInfo androidPromptInfo,
    IOSPromptInfo iosPromptInfo,
  ) {
    throw UnimplementedError('verify() has not been implemented.');
  }
}
