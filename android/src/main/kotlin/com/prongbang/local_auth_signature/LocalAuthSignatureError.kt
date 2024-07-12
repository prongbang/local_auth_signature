package com.prongbang.local_auth_signature

object LocalAuthSignatureError {
    const val KEY_IS_NULL = "KeyIsNull"
    const val PK_IS_NULL = "PkIsNull"
    const val PAYLOAD_IS_NULL = "PayloadIsNull"
    const val SIGNATURE_IS_NULL = "SignatureIsNull"
    const val NO_FRAGMENT_ACTIVITY = "NoFragmentActivity"
    const val CANCELED = "Canceled"
    const val LOCKED_OUT = "LockedOut"
    const val PERMANENTLY_LOCKED_OUT = "PermanentlyLockedOut"
    const val ERROR = "Error"
}