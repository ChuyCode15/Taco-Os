package com.tacoos.poc.data.local

import android.content.Context
import android.content.SharedPreferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.tacoos.poc.domain.model.User
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore by preferencesDataStore(name = "user_session")

/**
 * Clase encargada de gestionar las preferencias y la sesión del usuario de forma persistente.
 * Implementa una estrategia de almacenamiento híbrida:
 * 1. **Jetpack DataStore:** Para datos generales y estado de la sesión (nickname, rol, etc.).
 * 2. **EncryptedSharedPreferences:** Para información sensible (tokens) utilizando cifrado de hardware AES-256.
 */
@Singleton
class UserPreferences @Inject constructor(
    private val context: Context
) {
    /**
     * MasterKey vinculada al hardware del dispositivo (Android Keystore) para el cifrado/descifrado de datos.
     */
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    /**
     * Instancia de almacenamiento cifrado. Los datos aquí guardados son ilegibles sin la clave de hardware.
     */
    private val encryptedPrefs: SharedPreferences = EncryptedSharedPreferences.create(
        context,
        "secure_user_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    /**
     * Claves utilizadas para identificar los datos almacenados.
     */
    private object Keys {
        val USER_ID = stringPreferencesKey("user_id")
        val ID_GOOGLE = stringPreferencesKey("id_google")
        val NICKNAME = stringPreferencesKey("nickname")
        val EMAIL = stringPreferencesKey("email")
        val ROL = stringPreferencesKey("rol")
        val TIENE_NEGOCIO = booleanPreferencesKey("tiene_negocio")
        val NEGOCIO_ID = stringPreferencesKey("negocio_id")
        val NEGOCIO_NOMBRE = stringPreferencesKey("negocio_nombre")
        
        // Claves para SharedPreferences cifrado
        const val ACCESS_TOKEN = "access_token"
        const val REFRESH_TOKEN = "refresh_token"
    }

    /**
     * Flujo que proporciona la información del usuario actual.
     * Emite null si no hay una sesión activa.
     */
    val session: Flow<User?> = context.dataStore.data.map { prefs ->
        val userId = prefs[Keys.USER_ID] ?: return@map null
        User(
            id = userId,
            idGoogle = prefs[Keys.ID_GOOGLE].orEmpty(),
            nickname = prefs[Keys.NICKNAME].orEmpty(),
            email = prefs[Keys.EMAIL].orEmpty(),
            rol = prefs[Keys.ROL].orEmpty(),
            tieneNegocio = prefs[Keys.TIENE_NEGOCIO] ?: false,
            negocioId = prefs[Keys.NEGOCIO_ID],
            negocioNombre = prefs[Keys.NEGOCIO_NOMBRE]
        )
    }

    /**
     * Guarda la información de la sesión del usuario y cifra sus tokens.
     * @param user Datos del usuario a persistir en DataStore.
     * @param accessToken Token de acceso a cifrar.
     * @param refreshToken Token de refresco a cifrar.
     */
    suspend fun saveSession(user: User, accessToken: String, refreshToken: String?) {
        // Guardar datos no sensibles en DataStore
        context.dataStore.edit { prefs ->
            prefs[Keys.USER_ID] = user.id
            prefs[Keys.ID_GOOGLE] = user.idGoogle
            prefs[Keys.NICKNAME] = user.nickname
            prefs[Keys.EMAIL] = user.email
            prefs[Keys.ROL] = user.rol
            prefs[Keys.TIENE_NEGOCIO] = user.tieneNegocio
            prefs[Keys.NEGOCIO_ID] = user.negocioId.orEmpty()
            prefs[Keys.NEGOCIO_NOMBRE] = user.negocioNombre.orEmpty()
        }
        
        // Guardar tokens de forma segura en EncryptedSharedPreferences
        encryptedPrefs.edit().apply {
            putString(Keys.ACCESS_TOKEN, accessToken)
            putString(Keys.REFRESH_TOKEN, refreshToken)
            apply()
        }
    }

    /**
     * Recupera el token de acceso descifrado.
     * @return El token de acceso o null si no existe.
     */
    fun getAccessToken(): String? =
        encryptedPrefs.getString(Keys.ACCESS_TOKEN, null)

    /**
     * Elimina todos los datos de la sesión, tanto los normales como los cifrados.
     */
    suspend fun clear() {
        context.dataStore.edit { it.clear() }
        encryptedPrefs.edit().clear().apply()
    }
}
