
import 'local_auth_signature_platform_interface.dart';

class LocalAuthSignature {
  Future<String?> getPlatformVersion() {
    return LocalAuthSignaturePlatform.instance.getPlatformVersion();
  }
}
