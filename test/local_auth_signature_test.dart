import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_signature/local_auth_signature.dart';
import 'package:local_auth_signature/local_auth_signature_platform_interface.dart';
import 'package:local_auth_signature/local_auth_signature_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLocalAuthSignaturePlatform
    with MockPlatformInterfaceMixin
    implements LocalAuthSignaturePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LocalAuthSignaturePlatform initialPlatform = LocalAuthSignaturePlatform.instance;

  test('$MethodChannelLocalAuthSignature is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLocalAuthSignature>());
  });

  test('getPlatformVersion', () async {
    LocalAuthSignature localAuthSignaturePlugin = LocalAuthSignature();
    MockLocalAuthSignaturePlatform fakePlatform = MockLocalAuthSignaturePlatform();
    LocalAuthSignaturePlatform.instance = fakePlatform;

    expect(await localAuthSignaturePlugin.getPlatformVersion(), '42');
  });
}
