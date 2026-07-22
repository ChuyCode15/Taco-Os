package com.tacoos.poc.data.local

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.room.*
import java.io.ByteArrayOutputStream

/**
 * Converters: Clase de utilidad para Room que permite persistir tipos complejos (Bitmap).
 */
class Converters {
    @TypeConverter
    fun fromBitmap(bitmap: Bitmap?): ByteArray? {
        if (bitmap == null) return null
        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 70, outputStream)
        return outputStream.toByteArray()
    }

    @TypeConverter
    fun toBitmap(byteArray: ByteArray?): Bitmap? {
        if (byteArray == null) return null
        return BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
    }
}

/**
 * Entidad User: Representa el perfil del usuario autenticado en la DB local.
 */
@Entity(tableName = "users")
data class User(
    @PrimaryKey val id: String,
    val idGoogle: String,
    val nombre: String,
    val email: String,
    val rol: String,
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
 * Entidad Sale: Registro de transacciones individuales.
 * Se expande para soportar auditoría completa (método de pago, ítems y voucher).
 */
@Entity(tableName = "sales")
data class Sale(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val amount: Double,
    val method: String = "Efectivo",
    val status: String = "Cobrada",
    val itemsJson: String = "", // Resumen de productos en formato String
    val voucherPhoto: Bitmap? = null,
    val timestamp: Long = System.currentTimeMillis(),
    val isSynced: Boolean = false,
    val negocioId: String
)

/**
 * Entidad Expense: Registro de gastos operativos asociados al turno.
 */
@Entity(tableName = "expenses")
data class Expense(
    @PrimaryKey val id: String,
    val detail: String,
    val amount: Double,
    val cashier: String,
    val timestamp: Long = System.currentTimeMillis(),
    val receiptPhoto: Bitmap? = null,
    val isSynced: Boolean = false,
    val negocioId: String,
    val userId: String,
    val productsJson: String,
    val status: String = "ACTIVE" // ACTIVE, CANCELLED
)



@Dao
interface SaleDao {
    @Query("SELECT * FROM sales ORDER BY timestamp DESC")
    suspend fun getAllSales(): List<Sale>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSale(sale: Sale)

    @Query("SELECT SUM(amount) FROM sales WHERE timestamp >= :todayStart AND status = 'Cobrada'")
    suspend fun getTodayTotal(todayStart: Long): Double?
}

@Dao
interface ExpenseDao {
    @Query("SELECT * FROM expenses ORDER BY timestamp DESC")
    suspend fun getAllExpenses(): List<Expense>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertExpense(expense: Expense)

    @Query("SELECT SUM(amount) FROM expenses WHERE timestamp >= :todayStart AND status = 'ACTIVE'")
    suspend fun getTodayTotal(todayStart: Long): Double?

    @Query("SELECT * FROM sales WHERE negocioId = :negocioId AND timestamp BETWEEN :startDate AND :endDate")
    suspend fun getSalesByRange(negocioId: String, startDate: Long, endDate: Long): List<Sale>
}



@Dao
interface UserDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: User)

    @Query("SELECT * FROM users LIMIT 1")
    suspend fun getCurrentUser(): User?

    @Query("SELECT * FROM users WHERE negocioId = :negocioId AND rol = 'cajero'")
    suspend fun getCashiers(negocioId: String): List<User>

    @Query("DELETE FROM users")
    suspend fun clearUser()
}

@Dao
interface BusinessDao {
    @Insert
    suspend fun insertBusiness(business: Business)

    @Query("SELECT * FROM business WHERE id = :id")
    suspend fun getBusiness(id: String): Business?
}

@Entity(tableName = "app_metadata")
data class AppMetadata(
    @PrimaryKey val id: Int = 1,
    val lastLoginTimestamp: Long,
    val lastMasterSyncTimestamp: Long,
    val isLicenseValid: Boolean = true
)

@Dao
interface MetadataDao {
    @Query("SELECT * FROM app_metadata WHERE id = 1")
    suspend fun getMetadata(): AppMetadata?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun updateMetadata(metadata: AppMetadata)
}

/**
 * AppDatabase: Actualizada a versión 4 para incluir fotos y gastos.
 */
@Database(entities = [Sale::class, User::class, Business::class, AppMetadata::class, Expense::class], version = 4, exportSchema = false)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun saleDao(): SaleDao
    abstract fun expenseDao(): ExpenseDao
    abstract fun userDao(): UserDao
    abstract fun businessDao(): BusinessDao
    abstract fun metadataDao(): MetadataDao
}


