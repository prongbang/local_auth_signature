import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth_signature/local_auth_signature.dart';

/// An implementation of [LocalAuthSignature] that uses method channels.
class MethodChannelLocalAuthSignature extends LocalAuthSignature {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('local_auth_signature');

  @override
  Future<KeyChangedStatus?> isBiometricChanged(String key) async {
    final status = await methodChannel
        .invokeMethod<String>('isBiometricChanged', {'key': key});
    if (status == 'changed') {
      return KeyChangedStatus.changed;
    }
    return KeyChangedStatus.unchanged;
  }

  @override
  Future<String?> createKeyPair(
    String key,
    AndroidPromptInfo androidPromptInfo,
    IOSPromptInfo iosPromptInfo,
  ) async {
    if (Platform.isIOS) {
      return await methodChannel.invokeMethod<String>('createKeyPair', {
        'key': key,
        'reason': iosPromptInfo.reason,
      });
    }

    return await methodChannel.invokeMethod<String>('createKeyPair', {
      'key': key,
      'title': androidPromptInfo.title,
      'subtitle': androidPromptInfo.subtitle,
      'description': androidPromptInfo.description,
      'negativeButton': androidPromptInfo.negativeButton,
      'invalidatedByBiometricEnrollment':
          androidPromptInfo.invalidatedByBiometricEnrollment,
    });
  }

  @override
  Future<String?> sign(
    String key,
    String payload,
    AndroidPromptInfo androidPromptInfo,
    IOSPromptInfo iosPromptInfo,
  ) async {
    if (Platform.isIOS) {
      return await methodChannel.invokeMethod<String>('sign', {
        'key': key,
        'payload': payload,
        'reason': iosPromptInfo.reason,
      });
    }

    return await methodChannel.invokeMethod<String>('sign', {
      'key': key,
      'payload': payload,
      'title': androidPromptInfo.title,
      'subtitle': androidPromptInfo.subtitle,
      'description': androidPromptInfo.description,
      'negativeButton': androidPromptInfo.negativeButton,
      'invalidatedByBiometricEnrollment':
          androidPromptInfo.invalidatedByBiometricEnrollment,
    });
  }

  @override
  Future<bool> verify(
    String key,
    String payload,
    String signature,
    AndroidPromptInfo androidPromptInfo,
    IOSPromptInfo iosPromptInfo,
  ) async {
    if (Platform.isIOS) {
      return await methodChannel.invokeMethod<bool>('verify', {
            'key': key,
            'payload': payload,
            'signature': signature,
            'reason': iosPromptInfo.reason,
          }) ??
          false;
    }

    return await methodChannel.invokeMethod<bool>('verify', {
          'key': key,
          'payload': payload,
          'signature': signature,
          'title': androidPromptInfo.title,
          'subtitle': androidPromptInfo.subtitle,
          'description': androidPromptInfo.description,
          'negativeButton': androidPromptInfo.negativeButton,
          'invalidatedByBiometricEnrollment':
              androidPromptInfo.invalidatedByBiometricEnrollment,
        }) ??
        false;
  }
}
