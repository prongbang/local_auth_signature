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
        }) ??
        false;
  }

  @override
  Future<String?> keyChanged(String key, String pk) async {
    return await methodChannel.invokeMethod<String>('keyChanged', {
      'key': key,
      'pk': pk,
    });
  }
}
