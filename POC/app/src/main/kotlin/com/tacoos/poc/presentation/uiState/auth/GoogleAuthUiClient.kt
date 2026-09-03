package com.tacoos.poc.presentation.uiState.auth

import android.content.Context
import android.util.Base64
import android.util.Log
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialException
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.tacoos.poc.BuildConfig
import org.json.JSONObject
import java.security.SecureRandom

/**
 * Modelo de datos que representa la información del usuario obtenida de Google.
 *
 * @property idToken Token de identidad proporcionado por Google.
 * @property idGoogle ID único del usuario en Google.
 * @property email Correo electrónico del usuario.
 * @property nickname Nombre para mostrar del usuario.
 */
data class GoogleUserData(
    val idToken: String,
    val idGoogle: String,
    val email: String,
    val nickname: String? = null
)

/**
 * Cliente para gestionar la autenticación con Google utilizando Credential Manager.
 *
 * @param context Contexto de la aplicación.
 */
class GoogleAuthUiClient(private val context: Context) {

    private val TAG = "GoogleAuthUiClient"
    private val credentialManager = CredentialManager.create(context)

    /**
     * Solicita un ID Token de Google.
     *
     * @param filterByAuthorizedAccounts Si es true, solo muestra cuentas que ya han autorizado la app.
     * @return Resultado con [GoogleUserData] o una excepción.
     */
    suspend fun requestIdToken(filterByAuthorizedAccounts: Boolean): Result<GoogleUserData> {
        Log.d(TAG, "Iniciando solicitud de token. ClientID: ${BuildConfig.GOOGLE_CLIENT_ID}")
        Log.d(TAG, "Filtro de cuentas autorizadas: $filterByAuthorizedAccounts")

        val googleIdOption = if (filterByAuthorizedAccounts) {
            GetGoogleIdOption.Builder()
                .setFilterByAuthorizedAccounts(true)
                .setServerClientId(BuildConfig.GOOGLE_CLIENT_ID)
                .setAutoSelectEnabled(true)
                .setNonce(generateNonce())
                .build()
        } else {
            GetSignInWithGoogleOption.Builder(serverClientId = BuildConfig.GOOGLE_CLIENT_ID)
                .setNonce(generateNonce())
                .build()
        }

        val request = GetCredentialRequest.Builder()
            .addCredentialOption(googleIdOption)
            .build()

        return try {
            val result = credentialManager.getCredential(context, request)
            Log.d(TAG, "Credencial obtenida con éxito")
            val googleIdTokenCredential = GoogleIdTokenCredential.createFrom(result.credential.data)
            
            // Extraer sub (ID numérico) y email del ID Token (JWT)
            val (idGoogle, email) = decodeIdToken(googleIdTokenCredential.idToken)
            
            Result.success(
                GoogleUserData(
                    idToken = googleIdTokenCredential.idToken,
                    idGoogle = idGoogle ?: googleIdTokenCredential.id,
                    email = email ?: googleIdTokenCredential.id,
                    nickname = googleIdTokenCredential.displayName
                )
            )
        } catch (e: GetCredentialException) {
            Log.e(TAG, "Error de CredentialManager: ${e.type} - ${e.message}")
            Result.failure(e)
        } catch (e: Exception) {
            Log.e(TAG, "Error inesperado en Google Auth", e)
            Result.failure(e)
        }
    }

    /**
     * Decodifica el ID Token (JWT) para extraer información del usuario.
     *
     * @param idToken El token JWT a decodificar.
     * @return Un par que contiene el ID de Google (sub) y el email.
     */
    private fun decodeIdToken(idToken: String): Pair<String?, String?> {
        return try {
            val parts = idToken.split(".")
            if (parts.size < 2) return null to null
            
            val payload = String(Base64.decode(parts[1], Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING))
            val jsonObject = JSONObject(payload)
            
            val sub = jsonObject.optString("sub")
            val email = jsonObject.optString("email")
            
            sub to email
        } catch (e: Exception) {
            null to null
        }
    }

    /**
     * Genera un valor nonce aleatorio para la solicitud de autenticación.
     *
     * @return Cadena nonce codificada en Base64.
     */
    private fun generateNonce(): String {
        val bytes = ByteArray(32)
        SecureRandom().nextBytes(bytes)
        return Base64.encodeToString(bytes, Base64.NO_WRAP or Base64.URL_SAFE or Base64.NO_PADDING)
    }
}
