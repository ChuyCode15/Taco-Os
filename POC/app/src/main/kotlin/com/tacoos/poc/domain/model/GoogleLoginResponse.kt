
/**
 * Información devuelta por el servidor tras una autenticación exitosa con Google.
 * @property userId Identificador único interno del usuario.
 * @property email Correo electrónico asociado.
 * @property name Nombre completo o nickname del usuario.
 * @property accessToken Token de acceso para realizar peticiones protegidas.
 */
data class GoogleLoginResponse(
    val userId: String,
    val email: String,
    val name: String,
    val accessToken: String
)
