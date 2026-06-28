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
    val negocioId: String
)

@Dao
interface SaleDao {
    @Query("SELECT * FROM sales ORDER BY timestamp DESC")
    suspend fun getAllSales(): List<Sale>

    @Insert
    suspend fun insertSale(sale: Sale): Unit

    @Query("SELECT SUM(amount) FROM sales WHERE timestamp >= :todayStart")
    suspend fun getTodayTotal(todayStart: Long): Double?
}

@Dao
interface UserDao {
    @Insert
    suspend fun insertUser(user: User): Unit

    @Query("SELECT * FROM users LIMIT 1")
    suspend fun getCurrentUser(): User?

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

@Database(entities = [Sale::class, User::class, Business::class, AppMetadata::class], version = 3)
abstract class AppDatabase : RoomDatabase() {
    abstract fun saleDao(): SaleDao
    abstract fun userDao(): UserDao
    abstract fun businessDao(): BusinessDao
    abstract fun metadataDao(): MetadataDao
}

@Dao
interface MetadataDao {
    @Query("SELECT * FROM app_metadata WHERE id = 1")
    suspend fun getMetadata(): AppMetadata?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun updateMetadata(metadata: AppMetadata): Unit
}
