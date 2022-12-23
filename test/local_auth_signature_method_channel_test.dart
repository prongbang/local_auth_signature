import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_signature/local_auth_signature_method_channel.dart';

void main() {
  MethodChannelLocalAuthSignature platform = MethodChannelLocalAuthSignature();
  const MethodChannel channel = MethodChannel('local_auth_signature');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
