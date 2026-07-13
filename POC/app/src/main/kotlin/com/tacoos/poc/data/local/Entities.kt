package com.tacoos.poc.data.local

import androidx.room.OnConflictStrategy
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Database
import androidx.room.RoomDatabase

/**
 * Entidad User: Representa el perfil del usuario autenticado en la DB local.
 */
@Entity(tableName = "users")
data class User(
    @PrimaryKey val id: String, // UUID generado por el servidor.
    val idGoogle: String,
    val nombre: String,
    val email: String,
    val rol: String, // "dueño", "administrador" o "cajero".
    val negocioId: String? = null
)

/**
 * Entidad Business: Información básica del establecimiento comercial.
 */
@Entity(tableName = "business")
data class Business(
    @PrimaryKey val id: String,
    val nombre: String,
    val direccion: String,
    val telefono: String,
    val moneda: String,
    val dineroBase: Double
)

/**
 * Entidad Sale: Registro de transacciones individuales para permitir operación Offline.
 */
@Entity(tableName = "sales")
data class Sale(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val amount: Double,
    val timestamp: Long = System.currentTimeMillis(),
    val isSynced: Boolean = false, // Marca para el SyncWorker.
    val negocioId: String
)

/**
 * SaleDao: Interfaz de acceso a datos para operaciones de venta en SQLite.
 */
@Dao
interface SaleDao {
    @Query("SELECT * FROM sales ORDER BY timestamp DESC")
    suspend fun getAllSales(): List<Sale>

    @Insert
    suspend fun insertSale(sale: Sale)

    @Query("SELECT SUM(amount) FROM sales WHERE timestamp >= :todayStart")
    suspend fun getTodayTotal(todayStart: Long): Double?
}

/**
 * UserDao: Gestión del perfil de usuario local (Single user por sesión).
 */
@Dao
interface UserDao {
    @Insert
    suspend fun insertUser(user: User)

    @Query("SELECT * FROM users LIMIT 1")
    suspend fun getCurrentUser(): User?

    @Query("DELETE FROM users")
    suspend fun clearUser()
}

/**
 * BusinessDao: Acceso a la configuración del negocio local.
 */
@Dao
interface BusinessDao {
    @Insert
    suspend fun insertBusiness(business: Business)

    @Query("SELECT * FROM business WHERE id = :id")
    suspend fun getBusiness(id: String): Business?
}

/**
 * Entidad AppMetadata: Metadata técnica para control de licencias y expiración de sesiones.
 */
@Entity(tableName = "app_metadata")
data class AppMetadata(
    @PrimaryKey val id: Int = 1,
    val lastLoginTimestamp: Long,
    val lastMasterSyncTimestamp: Long,
    val isLicenseValid: Boolean = true
)

/**
 * AppDatabase: Clase abstracta de Room que define la arquitectura de la DB SQLite.
 * exportSchema = false: Simplifica el despliegue del POC al no requerir archivos JSON de migración externos.
 */
@Database(entities = [Sale::class, User::class, Business::class, AppMetadata::class], version = 3, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun saleDao(): SaleDao
    abstract fun userDao(): UserDao
    abstract fun businessDao(): BusinessDao
    abstract fun metadataDao(): MetadataDao
}

/**
 * MetadataDao: Operaciones sobre la metadata técnica de la aplicación.
 */
@Dao
interface MetadataDao {
    @Query("SELECT * FROM app_metadata WHERE id = 1")
    suspend fun getMetadata(): AppMetadata?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun updateMetadata(metadata: AppMetadata)
}
