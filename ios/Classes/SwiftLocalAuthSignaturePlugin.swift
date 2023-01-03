import Flutter
import UIKit
import SignatureBiometricSwift

public class SwiftLocalAuthSignaturePlugin: NSObject, FlutterPlugin {
    
    private var signatureBiometricManager: SignatureBiometricManager?=nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "local_auth_signature", binaryMessenger: registrar.messenger())
        let instance = SwiftLocalAuthSignaturePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, String> else {
            result(
                FlutterError(
                    code: SwiftLocalAuthSignatureError.ArgsIsNull,
                    message: "Arguments is null",
                    details: nil
                )
            )
            return
        }
        
        guard let key = args[SwiftLocalAuthSignatureArgs.Key] else {
            result(
                FlutterError(
                    code: SwiftLocalAuthSignatureError.KeyIsNull,
                    message: "Key is null",
                    details: nil
                )
            )
            return
        }
        
        switch call.method {
        case SwiftLocalAuthSignatureMethod.CreateKeyPair:
            guard let reason = args[SwiftLocalAuthSignatureArgs.Reason] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ReasonIsNull,
                        message: "Reason is null",
                        details: nil
                    )
                )
                return
            }
            
            let keyConfig = KeyConfig(name: key)
            let signatureBiometricManager = LocalSignatureBiometricManager.newInstance(keyConfig: keyConfig)
            signatureBiometricManager.createKeyPair(reason: reason) { value in
                if value.status == SignatureBiometricStatus.success {
                    result(value.publicKey)
                } else {
                    result(
                        FlutterError(
                            code: value.status,
                            message: "Error is \(value.status)",
                            details: nil
                        )
                    )
                }
            }
            
            break
        case SwiftLocalAuthSignatureMethod.Sign:
            guard let payload = args[SwiftLocalAuthSignatureArgs.Payload] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.PayloadIsNull,
                        message: "Payload is null",
                        details: nil
                    )
                )
                return
            }
            
            let keyConfig = KeyConfig(name: key)
            let signatureBiometricManager = LocalSignatureBiometricManager.newInstance(keyConfig: keyConfig)
            signatureBiometricManager.sign(payload: payload) { value in
                if value.status == SignatureBiometricStatus.success {
                    result(value.signature)
                } else {
                    result(
                        FlutterError(
                            code: value.status,
                            message: "Error is \(value.status)",
                            details: nil
                        )
                    )
                }
            }
            break
        case SwiftLocalAuthSignatureMethod.Verify:
            guard let reason = args[SwiftLocalAuthSignatureArgs.Reason] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.ReasonIsNull,
                        message: "Reason is null",
                        details: nil
                    )
                )
                return
            }
            guard let payload = args[SwiftLocalAuthSignatureArgs.Payload] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.PayloadIsNull,
                        message: "Payload is null",
                        details: nil
                    )
                )
                return
            }
            guard let signature = args[SwiftLocalAuthSignatureArgs.Signature] else {
                result(
                    FlutterError(
                        code: SwiftLocalAuthSignatureError.SignatureIsNull,
                        message: "Signature is null",
                        details: nil
                    )
                )
                return
            }
            
            let keyConfig = KeyConfig(name: key)
            let signatureBiometricManager = LocalSignatureBiometricManager.newInstance(keyConfig: keyConfig)
            signatureBiometricManager.verify(reason: reason, payload: payload, signature: signature) { value in
                if value.status == SignatureBiometricStatus.success {
                    result(value.verified)
                } else {
                    result(
                        FlutterError(
                            code: value.status,
                            message: "Error is \(value.status)",
                            details: nil
                        )
                    )
                }
            }
            break
        default:
            result(nil)
        }
        
    }
    
}
