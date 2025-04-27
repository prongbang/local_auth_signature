# local_auth_signature 🔐

[![pub package](https://img.shields.io/pub/v/local_auth_signature.svg)](https://pub.dartlang.org/packages/local_auth_signature)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-green.svg)](https://flutter.dev/multi-platform)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> Generate key pairs and cryptographic signatures using NIST P-256 EC key pair with ECDSA, protected by biometric authentication for Flutter (Android & iOS).

![Screenshot](screenshot/screenshot.jpg)

## ✨ Features

- 🔑 **Secure Key Generation** - Generate NIST P-256 EC key pairs
- 🔒 **Biometric Protection** - Keys protected by fingerprint or Face ID
- ✍️ **Digital Signatures** - Create and verify ECDSA signatures
- 📱 **Cross-Platform** - Works on both Android and iOS
- 🔄 **Biometric Change Detection** - Detect when biometric data changes
- 💾 **Secure Storage** - Keys stored securely in platform keystore

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  local_auth_signature: ^1.0.12
```

Then run:
```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Import the Package

```dart
import 'package:local_auth_signature/local_auth_signature.dart';
```

### 2. Initialize

```dart
final _localAuthSignature = LocalAuthSignature.instance;
final _key = 'com.yourapp.signatureKey';
```

### 3. Generate Key Pair

```dart
try {
  final publicKey = await _localAuthSignature.createKeyPair(
    _key,
    AndroidPromptInfo(
      title: 'BIOMETRIC',
      subtitle: 'Please allow biometric',
      negativeButton: 'CANCEL',
    ),
    IOSPromptInfo(reason: 'Please allow biometric'),
  );
  print('Public Key: $publicKey');
} on PlatformException catch (e) {
  print('Error: ${e.code}');
}
```

## 📱 Platform Setup

### 🤖 Android Setup

1. Update `MainActivity.kt`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

2. Add permissions to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

3. Add JitPack repository to `build.gradle`:

```groovy
buildscript {
    repositories {
        maven { url "https://jitpack.io" }
    }
}

allprojects {
    repositories {
        maven { url "https://jitpack.io" }
    }
}
```

### 🍎 iOS Setup

Add to your `Info.plist`:

```xml
<dict>
  <key>NSFaceIDUsageDescription</key>
  <string>This application wants to access your TouchID or FaceID</string>
</dict>
```

## 📚 API Reference

### Biometric Changes

#### Check if Biometrics Changed
```dart
final bool hasChanged = await _localAuthSignature.isBiometricChanged(_key);
```

#### Reset Biometric Status (iOS only)
```dart
await _localAuthSignature.resetBiometricChanged();
```

### Key Management

#### Create Key Pair
```dart
final String publicKey = await _localAuthSignature.createKeyPair(
  keyName,
  androidPrompt,
  iosPrompt,
);
```

#### Sign Data
```dart
final String signature = await _localAuthSignature.sign(
  keyName,
  payload,
  androidPrompt,
  iosPrompt,
);
```

#### Verify Signature
```dart
final bool isValid = await _localAuthSignature.verify(
  keyName,
  payload,
  signature,
  androidPrompt,
  iosPrompt,
);
```

## 💡 Complete Example

```dart
class BiometricSignature {
  final _localAuthSignature = LocalAuthSignature.instance;
  final _key = 'com.yourapp.biometric.key';
  final _payload = 'Hello, World!';
  
  Future<void> demonstrateSignature() async {
    try {
      // Check if biometrics changed
      final changed = await _localAuthSignature.isBiometricChanged(_key);
      if (changed) {
        // Handle biometric enrollment changes
        print('Biometrics have changed!');
      }
      
      // Create key pair
      final publicKey = await _localAuthSignature.createKeyPair(
        _key,
        AndroidPromptInfo(
          title: 'Create Key',
          subtitle: 'Authenticate to create secure key',
          negativeButton: 'Cancel',
        ),
        IOSPromptInfo(reason: 'Authenticate to create secure key'),
      );
      print('Public Key: $publicKey');
      
      // Sign data
      final signature = await _localAuthSignature.sign(
        _key,
        _payload,
        AndroidPromptInfo(
          title: 'Sign Data',
          subtitle: 'Authenticate to sign',
          negativeButton: 'Cancel',
        ),
        IOSPromptInfo(reason: 'Authenticate to sign'),
      );
      print('Signature: $signature');
      
      // Verify signature
      final verified = await _localAuthSignature.verify(
        _key,
        _payload,
        signature,
        AndroidPromptInfo(
          title: 'Verify Signature',
          subtitle: 'Authenticate to verify',
          negativeButton: 'Cancel',
        ),
        IOSPromptInfo(reason: 'Authenticate to verify'),
      );
      print('Verified: $verified');
      
    } on PlatformException catch (e) {
      handleError(e);
    }
  }
  
  void handleError(PlatformException e) {
    switch (e.code) {
      case 'auth_failed':
        print('Authentication failed');
        break;
      case 'not_available':
        print('Biometric authentication not available');
        break;
      case 'user_cancel':
        print('User cancelled authentication');
        break;
      default:
        print('Error: ${e.code} - ${e.message}');
    }
  }
}
```

## 🔍 Error Handling

Common error codes:

| Code | Description |
|------|-------------|
| `auth_failed` | Authentication failed |
| `not_available` | Biometric authentication not available |
| `user_cancel` | User cancelled authentication |
| `key_not_found` | Key not found in keystore |
| `biometric_changed` | Biometric enrollment has changed |

## 🔒 Security Considerations

1. **Key Storage**: Private keys are stored in platform-specific secure storage
2. **Biometric Protection**: Keys require biometric authentication to use
3. **Change Detection**: Keys become invalid when biometric data changes
4. **Platform Security**: Leverages Android Keystore and iOS Secure Enclave

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💖 Support the Project

If you find this package helpful, please consider supporting it:

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/prongbang)

## 🔗 Related Projects

- [Android Biometric Signature](https://github.com/prongbang/android-biometric-signature)
- [SignatureBiometricSwift](https://github.com/prongbang/SignatureBiometricSwift)

---
