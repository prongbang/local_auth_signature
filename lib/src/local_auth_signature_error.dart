import 'package:flutter/services.dart';

extension PlatformExceptionExt on PlatformException {
  bool get isPasscodeNotSet => code == LocalAuthSignatureError.passcodeNotSet;

  bool get isNotEnrolled => code == LocalAuthSignatureError.notEnrolled;

  bool get isLockedOut => code == LocalAuthSignatureError.lockedOut;

  bool get isPermanentlyLockedOut =>
      code == LocalAuthSignatureError.permanentlyLockedOut;

  bool get isNotPaired => code == LocalAuthSignatureError.notPaired;

  bool get isDisconnected => code == LocalAuthSignatureError.disconnected;

  bool get isInvalidDimensions =>
      code == LocalAuthSignatureError.invalidDimensions;

  bool get isNotAvailable => code == LocalAuthSignatureError.notAvailable;

  bool get isUserFallback => code == LocalAuthSignatureError.userFallback;

  bool get isAuthenticationFailed =>
      code == LocalAuthSignatureError.authenticationFailed;

  bool get isCanceled => code == LocalAuthSignatureError.canceled;

  bool get isError => code == LocalAuthSignatureError.error;

  bool get isNotEvaluatePolicy =>
      code == LocalAuthSignatureError.notEvaluatePolicy;
}

class LocalAuthSignatureError {
  static const String passcodeNotSet = 'PasscodeNotSet';
  static const String notEnrolled = 'NotEnrolled';
  static const String lockedOut = 'LockedOut';
  static const String permanentlyLockedOut = 'PermanentlyLockedOut';
  static const String notPaired = 'NotPaired';
  static const String disconnected = 'Disconnected';
  static const String invalidDimensions = 'InvalidDimensions';
  static const String notAvailable = 'NotAvailable';
  static const String userFallback = 'UserFallback';
  static const String authenticationFailed = 'AuthenticationFailed';
  static const String canceled = 'Canceled';
  static const String error = 'Error';
  static const String notEvaluatePolicy = 'NotEvaluatePolicy';
}
