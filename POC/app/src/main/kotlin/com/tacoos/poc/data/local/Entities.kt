package com.tacoos.poc.data.local

import androidx.room.OnConflictStrategy
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Database
import androidx.room.RoomDatabase

@Entity(tableName = "users")
data class User(
    @PrimaryKey val id: String, // UUID as String
    val idGoogle: String,
    val nombre: String,
    val email: String,
    val rol: String, // "dueño" o "cajero"
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

@Entity(tableName = "sales")
data class Sale(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val amount: Double,
    val timestamp: Long = System.currentTimeMillis(),
    val isSynced: Boolean = false,
    val negocioId: String,
    val userId: String,
    val productsJson: String,
    val status: String = "ACTIVE" // ACTIVE, CANCELLED
)

@Entity(tableName = "expenses")
data class Expense(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val amount: Double,
    val description: String,
    val timestamp: Long = System.currentTimeMillis(),
    val negocioId: String,
    val userId: String,
    val isSynced: Boolean = false
)

@Dao
interface SaleDao {
    @Query("SELECT * FROM sales ORDER BY timestamp DESC")
    suspend fun getAllSales(): List<Sale>

    @Insert
    suspend fun insertSale(sale: Sale): Unit

    @Query("SELECT SUM(amount) FROM sales WHERE timestamp >= :todayStart AND status = 'ACTIVE'")
    suspend fun getTodayTotal(todayStart: Long): Double?

    @Query("SELECT * FROM sales WHERE negocioId = :negocioId AND timestamp BETWEEN :startDate AND :endDate")
    suspend fun getSalesByRange(negocioId: String, startDate: Long, endDate: Long): List<Sale>
}

@Dao
interface ExpenseDao {
    @Query("SELECT * FROM expenses WHERE negocioId = :negocioId AND timestamp BETWEEN :startDate AND :endDate")
    suspend fun getExpensesByRange(negocioId: String, startDate: Long, endDate: Long): List<Expense>

    @Insert
    suspend fun insertExpense(expense: Expense): Unit
}

@Dao
interface UserDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: User): Unit

    @Query("SELECT * FROM users LIMIT 1")
    suspend fun getCurrentUser(): User?

    @Query("SELECT * FROM users WHERE negocioId = :negocioId AND rol = 'cajero'")
    suspend fun getCashiers(negocioId: String): List<User>

    @Query("DELETE FROM users")
    suspend fun clearUser(): Unit
}

@Dao
interface BusinessDao {
    @Insert
    suspend fun insertBusiness(business: Business): Unit

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
    suspend fun updateMetadata(metadata: AppMetadata): Unit
}

@Database(entities = [Sale::class, User::class, Business::class, AppMetadata::class, Expense::class], version = 4, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun saleDao(): SaleDao
    abstract fun userDao(): UserDao
    abstract fun businessDao(): BusinessDao
    abstract fun metadataDao(): MetadataDao
    abstract fun expenseDao(): ExpenseDao
}
