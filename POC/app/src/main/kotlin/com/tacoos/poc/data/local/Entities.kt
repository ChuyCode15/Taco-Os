package com.tacoos.poc.data.local

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.room.*
import java.io.ByteArrayOutputStream

/**
 * Converters: Manejo de Bitmaps para Room.
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

@Entity(tableName = "users")
data class User(
    @PrimaryKey val id: String,
    val idGoogle: String,
    val nombre: String,
    val email: String,
    val rol: String,
    val negocioId: String? = null
)

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
 * Entidad Sale: Unificada para reportes y auditoría.
 */
@Entity(tableName = "sales")
data class Sale(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val amount: Double,
    val userId: String = "",
    val productsJson: String = "",
    val method: String = "Efectivo",
    val status: String = "ACTIVE", // ReportsScreen filtra por status == "ACTIVE"
    val voucherPhoto: Bitmap? = null,
    val timestamp: Long = System.currentTimeMillis(),
    val isSynced: Boolean = false,
    val negocioId: String
)

@Entity(tableName = "expenses")
data class Expense(
    @PrimaryKey val id: String,
    val detail: String,
    val amount: Double,
    val cashier: String,
    val timestamp: Long = System.currentTimeMillis(),
    val receiptPhoto: Bitmap? = null,
    val isSynced: Boolean = false,
    val negocioId: String
)

@Dao
interface SaleDao {
    @Query("SELECT * FROM sales ORDER BY timestamp DESC")
    suspend fun getAllSales(): List<Sale>

    @Query("SELECT * FROM sales WHERE negocioId = :negocioId AND timestamp BETWEEN :start AND :end")
    suspend fun getSalesByRange(negocioId: String, start: Long, end: Long): List<Sale>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSale(sale: Sale)

    @Query("UPDATE sales SET isSynced = 1 WHERE id = :id")
    suspend fun markAsSynced(id: Long)

    @Query("SELECT SUM(amount) FROM sales WHERE timestamp >= :todayStart AND status = 'ACTIVE'")
    suspend fun getTodayTotal(todayStart: Long): Double?
}

@Dao
interface ExpenseDao {
    @Query("SELECT * FROM expenses ORDER BY timestamp DESC")
    suspend fun getAllExpenses(): List<Expense>

    @Query("SELECT * FROM expenses WHERE negocioId = :negocioId AND timestamp BETWEEN :start AND :end")
    suspend fun getExpensesByRange(negocioId: String, start: Long, end: Long): List<Expense>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertExpense(expense: Expense)

    @Query("SELECT SUM(amount) FROM expenses WHERE timestamp >= :todayStart")
    suspend fun getTodayTotal(todayStart: Long): Double?
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
    @Insert(onConflict = OnConflictStrategy.REPLACE)
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

@Database(entities = [Sale::class, User::class, Business::class, AppMetadata::class, Expense::class], version = 5, exportSchema = false)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun saleDao(): SaleDao
    abstract fun expenseDao(): ExpenseDao
    abstract fun userDao(): UserDao
    abstract fun businessDao(): BusinessDao
    abstract fun metadataDao(): MetadataDao
}
