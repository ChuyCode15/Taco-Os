
/**
 * Representa la solicitud de inicio de sesión con el token de identidad de Google.
 * @property idToken El token JWT recibido desde el SDK de Google Sign-In.
 */
data class GoogleLoginRequest(val idToken: String)
