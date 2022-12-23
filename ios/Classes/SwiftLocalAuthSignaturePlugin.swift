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
            result(nil)
            return
        }
        
        guard let key = args[SwiftLocalAuthSignatureArgs.Key] else {
            result(nil)
            return
        }
        
        switch call.method {
        case SwiftLocalAuthSignatureMethod.CreateKeyPair:
            guard let reason = args[SwiftLocalAuthSignatureArgs.Reason] else {
                result(nil)
                return
            }
            
            let keyConfig = KeyConfig(name: key)
            let signatureBiometricManager = LocalSignatureBiometricManager.newInstance(keyConfig: keyConfig)
            signatureBiometricManager.createKeyPair(reason: reason) { value in
                result(value)
            }
          
            break
        case SwiftLocalAuthSignatureMethod.Sign:
            guard let payload = args[SwiftLocalAuthSignatureArgs.Payload] else {
                result(nil)
                return
            }
            
            let keyConfig = KeyConfig(name: key)
            let signatureBiometricManager = LocalSignatureBiometricManager.newInstance(keyConfig: keyConfig)
            signatureBiometricManager.sign(payload: payload) { signature in
                if signature != nil {
                    result(SignResult(payload: payload, signature: signature!))
                } else {
                    result(nil)
                }
            }
            break
        case SwiftLocalAuthSignatureMethod.Verify:
            guard let payload = args[SwiftLocalAuthSignatureArgs.Payload] else {
                result(nil)
                return
            }
            guard let signature = args[SwiftLocalAuthSignatureArgs.Signature] else {
                result(nil)
                return
            }
            
            let keyConfig = KeyConfig(name: key)
            let signatureBiometricManager = LocalSignatureBiometricManager.newInstance(keyConfig: keyConfig)
            signatureBiometricManager.verify(payload: payload, signature: signature) { verified in
                result(verified)
            }
            break
        default:
            result(nil)
        }
       
    }
    
}
