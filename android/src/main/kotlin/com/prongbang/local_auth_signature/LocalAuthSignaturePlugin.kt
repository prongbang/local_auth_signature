package com.prongbang.local_auth_signature

import android.os.Build
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import com.prongbang.biometricsignature.Biometric
import com.prongbang.biometricsignature.SignatureBiometricPromptManager
import com.prongbang.biometricsignature.exception.PublicKeyNotFoundException
import com.prongbang.biometricsignature.extensions.toBase64
import com.prongbang.biometricsignature.key.KeyStoreAliasKey
import com.prongbang.biometricsignature.keypair.BiometricKeyStoreManager
import com.prongbang.biometricsignature.signature.BiometricSignature

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** LocalAuthSignaturePlugin */
class LocalAuthSignaturePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: FragmentActivity? = null
    private val biometricKeyStoreManager by lazy { BiometricKeyStoreManager() }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "local_auth_signature")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            LocalAuthSignatureMethod.KEY_CHANGED -> {
                val bioKey = call.argument<String?>(LocalAuthSignatureArgs.BIO_KEY)
                if (bioKey == null) {
                    result.error(LocalAuthSignatureError.KEY_IS_NULL, "Key is null", null)
                    return
                }
                val bioPk = call.argument<String?>(LocalAuthSignatureArgs.BIO_PK)
                if (bioPk == null) {
                    result.error(LocalAuthSignatureError.PK_IS_NULL, "Pk is null", null)
                    return
                }
                if (activity == null) {
                    result.error(
                        LocalAuthSignatureError.NO_FRAGMENT_ACTIVITY,
                        "FragmentActivity is null",
                        null
                    )
                    return
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    try {
                        val publicKey = biometricKeyStoreManager.getPublicKey(key = bioKey)
                        if (publicKey.toBase64() == bioPk) {
                            result.success("unchanged")
                        } else {
                            result.success("changed")
                        }
                    } catch (_: PublicKeyNotFoundException) {
                        result.success("changed")
                    }
                } else {
                    result.success("sdk-unsupported")
                }
            }

            LocalAuthSignatureMethod.CREATE_KEYPAIR -> {
                val bioKey = call.argument<String?>(LocalAuthSignatureArgs.BIO_KEY)
                if (bioKey == null) {
                    result.error(LocalAuthSignatureError.KEY_IS_NULL, "Key is null", null)
                    return
                }
                if (activity == null) {
                    result.error(
                        LocalAuthSignatureError.NO_FRAGMENT_ACTIVITY,
                        "FragmentActivity is null",
                        null
                    )
                    return
                }
                val title = call.argument<String?>(LocalAuthSignatureArgs.BIO_TITLE)
                val subtitle = call.argument<String?>(LocalAuthSignatureArgs.BIO_SUBTITLE)
                val description = call.argument<String?>(LocalAuthSignatureArgs.BIO_DESCRIPTION)
                val negativeButton =
                    call.argument<String?>(LocalAuthSignatureArgs.BIO_NEGATIVE_BUTTON)
                val invalidatedByBiometricEnrollment =
                    call.argument<Boolean?>(LocalAuthSignatureArgs.BIO_INVALIDATED_BY_BIOMETRIC_ENROLLMENT)
                val promptInfo = Biometric.PromptInfo(
                    title = title ?: "",
                    subtitle = subtitle ?: "",
                    description = description ?: "",
                    negativeButton = negativeButton ?: "",
                    invalidatedByBiometricEnrollment = invalidatedByBiometricEnrollment ?: false,
                )
                val customKeyStoreAliasKey = object : KeyStoreAliasKey {
                    override fun key(): String = bioKey
                }
                val keyPairBiometricPromptManager =
                    SignatureBiometricPromptManager.newInstance(
                        activity!!,
                        keyStoreAliasKey = customKeyStoreAliasKey
                    )
                keyPairBiometricPromptManager.createKeyPair(
                    promptInfo,
                    object : SignatureBiometricPromptManager.Result {
                        override fun callback(biometric: Biometric) {
                            when (biometric.status) {
                                Biometric.Status.SUCCEEDED -> {
                                    val publicKey = biometric.keyPair?.publicKey
                                    result.success(publicKey)
                                }

                                Biometric.Status.ERROR -> {
                                    result.error(
                                        LocalAuthSignatureError.ERROR,
                                        "Biometric is error",
                                        null
                                    )
                                }

                                Biometric.Status.CANCEL -> {
                                    result.error(
                                        LocalAuthSignatureError.CANCELED,
                                        "Biometric is canceled",
                                        null
                                    )
                                }

                                Biometric.Status.LOCKOUT -> {
                                    result.error(
                                        LocalAuthSignatureError.LOCKED_OUT,
                                        "Biometric is locked out",
                                        null
                                    )
                                }

                                Biometric.Status.LOCKOUT_PERMANENT -> {
                                    result.error(
                                        LocalAuthSignatureError.PERMANENTLY_LOCKED_OUT,
                                        "Biometric is permanently locked out",
                                        null
                                    )
                                }
                            }
                        }
                    })
            }

            LocalAuthSignatureMethod.SIGN -> {
                val bioKey = call.argument<String?>(LocalAuthSignatureArgs.BIO_KEY)
                if (bioKey == null) {
                    result.error(LocalAuthSignatureError.KEY_IS_NULL, "Key is null", null)
                    return
                }
                val bioPayload = call.argument<String?>(LocalAuthSignatureArgs.BIO_PAYLOAD)
                if (bioPayload == null) {
                    result.error(LocalAuthSignatureError.PAYLOAD_IS_NULL, "Payload is null", null)
                    return
                }
                if (activity == null) {
                    result.error(
                        LocalAuthSignatureError.NO_FRAGMENT_ACTIVITY,
                        "FragmentActivity is null",
                        null
                    )
                    return
                }
                val title = call.argument<String?>(LocalAuthSignatureArgs.BIO_TITLE)
                val subtitle = call.argument<String?>(LocalAuthSignatureArgs.BIO_SUBTITLE)
                val description = call.argument<String?>(LocalAuthSignatureArgs.BIO_DESCRIPTION)
                val negativeButton =
                    call.argument<String?>(LocalAuthSignatureArgs.BIO_NEGATIVE_BUTTON)
                val invalidatedByBiometricEnrollment =
                    call.argument<Boolean?>(LocalAuthSignatureArgs.BIO_INVALIDATED_BY_BIOMETRIC_ENROLLMENT)
                val promptInfo = Biometric.PromptInfo(
                    title = title ?: "",
                    subtitle = subtitle ?: "",
                    description = description ?: "",
                    negativeButton = negativeButton ?: "",
                    invalidatedByBiometricEnrollment = invalidatedByBiometricEnrollment ?: false,
                )
                val customKeyStoreAliasKey = object : KeyStoreAliasKey {
                    override fun key(): String = bioKey
                }
                val payloadBiometricSignature = object : BiometricSignature() {
                    override fun payload(): String = bioPayload
                }

                val signBiometricPromptManager =
                    SignatureBiometricPromptManager.newInstance(
                        activity!!,
                        keyStoreAliasKey = customKeyStoreAliasKey,
                        biometricSignature = payloadBiometricSignature,
                    )
                signBiometricPromptManager.sign(
                    promptInfo,
                    object : SignatureBiometricPromptManager.Result {
                        override fun callback(biometric: Biometric) {
                            when (biometric.status) {
                                Biometric.Status.SUCCEEDED -> {
                                    val signature = biometric.signature
                                    result.success(signature?.signature)
                                }

                                Biometric.Status.ERROR -> {
                                    result.error(
                                        LocalAuthSignatureError.ERROR,
                                        "Biometric is error",
                                        null
                                    )
                                }

                                Biometric.Status.CANCEL -> {
                                    result.error(
                                        LocalAuthSignatureError.CANCELED,
                                        "Biometric is canceled",
                                        null
                                    )
                                }

                                Biometric.Status.LOCKOUT -> {
                                    result.error(
                                        LocalAuthSignatureError.LOCKED_OUT,
                                        "Biometric is locked out",
                                        null
                                    )
                                }

                                Biometric.Status.LOCKOUT_PERMANENT -> {
                                    result.error(
                                        LocalAuthSignatureError.PERMANENTLY_LOCKED_OUT,
                                        "Biometric is permanently locked out",
                                        null
                                    )
                                }
                            }
                        }
                    })
            }

            LocalAuthSignatureMethod.VERIFY -> {
                val bioKey = call.argument<String?>(LocalAuthSignatureArgs.BIO_KEY)
                if (bioKey == null) {
                    result.error(LocalAuthSignatureError.KEY_IS_NULL, "Key is null", null)
                    return
                }
                val bioPayload = call.argument<String?>(LocalAuthSignatureArgs.BIO_PAYLOAD)
                if (bioPayload == null) {
                    result.error(LocalAuthSignatureError.PAYLOAD_IS_NULL, "Payload is null", null)
                    return
                }
                val bioSignature = call.argument<String?>(LocalAuthSignatureArgs.BIO_SIGNATURE)
                if (bioSignature == null) {
                    result.error(
                        LocalAuthSignatureError.SIGNATURE_IS_NULL,
                        "Signature is null",
                        null
                    )
                    return
                }
                if (activity == null) {
                    result.error(
                        LocalAuthSignatureError.NO_FRAGMENT_ACTIVITY,
                        "FragmentActivity is null",
                        null
                    )
                    return
                }
                val title = call.argument<String?>(LocalAuthSignatureArgs.BIO_TITLE)
                val subtitle = call.argument<String?>(LocalAuthSignatureArgs.BIO_SUBTITLE)
                val description = call.argument<String?>(LocalAuthSignatureArgs.BIO_DESCRIPTION)
                val negativeButton =
                    call.argument<String?>(LocalAuthSignatureArgs.BIO_NEGATIVE_BUTTON)
                val invalidatedByBiometricEnrollment =
                    call.argument<Boolean?>(LocalAuthSignatureArgs.BIO_INVALIDATED_BY_BIOMETRIC_ENROLLMENT)
                val promptInfo = Biometric.PromptInfo(
                    title = title ?: "",
                    subtitle = subtitle ?: "",
                    description = description ?: "",
                    negativeButton = negativeButton ?: "",
                    invalidatedByBiometricEnrollment = invalidatedByBiometricEnrollment ?: false,
                )
                val customKeyStoreAliasKey = object : KeyStoreAliasKey {
                    override fun key(): String = bioKey
                }
                val payloadBiometricSignature = object : BiometricSignature() {
                    override fun payload(): String = bioPayload
                    override fun signature(): String = bioSignature
                }
                val verifyBiometricPromptManager = SignatureBiometricPromptManager.newInstance(
                    activity!!,
                    keyStoreAliasKey = customKeyStoreAliasKey,
                    biometricSignature = payloadBiometricSignature,
                )
                verifyBiometricPromptManager.verify(
                    promptInfo,
                    object : SignatureBiometricPromptManager.Result {
                        override fun callback(biometric: Biometric) {
                            when (biometric.status) {
                                Biometric.Status.SUCCEEDED -> {
                                    val verified = biometric.verify
                                    result.success(verified)
                                }

                                Biometric.Status.ERROR -> {
                                    result.error(
                                        LocalAuthSignatureError.ERROR,
                                        "Biometric is error",
                                        null
                                    )
                                }

                                Biometric.Status.CANCEL -> {
                                    result.error(
                                        LocalAuthSignatureError.CANCELED,
                                        "Biometric is canceled",
                                        null
                                    )
                                }

                                Biometric.Status.LOCKOUT -> {
                                    result.error(
                                        LocalAuthSignatureError.LOCKED_OUT,
                                        "Biometric is locked out",
                                        null
                                    )
                                }

                                Biometric.Status.LOCKOUT_PERMANENT -> {
                                    result.error(
                                        LocalAuthSignatureError.PERMANENTLY_LOCKED_OUT,
                                        "Biometric is permanently locked out",
                                        null
                                    )
                                }
                            }
                        }
                    })
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        activity = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivity() {}
}
