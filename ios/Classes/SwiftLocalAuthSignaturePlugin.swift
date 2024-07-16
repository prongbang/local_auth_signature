import Flutter
import UIKit
import SignatureBiometricSwift
import LocalAuthentication

public class SwiftLocalAuthSignaturePlugin: NSObject, FlutterPlugin {
    
    private var signatureBiometricManager: SignatureBiometricManager?=nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "local_auth_signature", binaryMessenger: registrar.messenger())
        let instance = SwiftLocalAuthSignaturePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func isBiometricChanged(name: String) -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Biometric authentication is not available
            return true
        }
        
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrApplicationTag as String: tag,
            kSecReturnRef as String: true,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIFail
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        switch status {
        case errSecSuccess:
            // Key exists and is accessible without authentication
            return false
        case errSecItemNotFound:
            // Key doesn't exist anymore, biometrics likely changed
            return true
        case errSecUserCanceled, errSecAuthFailed:
            // Key exists but requires authentication (which we've disabled)
            // Biometrics are still valid
            return false
        default:
            // Any other error suggests the key is not accessible, biometrics likely changed
            print("Unexpected error checking biometric state: \(status)")
            return true
        }
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
        case SwiftLocalAuthSignatureMethod.isBiometricChanged:
            
            let isChanged = isBiometricChanged(name: key)
            if isChanged {
                result("changed")
            } else {
                result("unchanged")
            }
            
            break
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
