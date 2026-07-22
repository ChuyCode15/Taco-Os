package com.tacoos.poc.data.local

import androidx.room.*
import java.util.*

@Entity(tableName = "users")
data class User(
    @PrimaryKey val id: String,
    val idGoogle: String,
    val nombre: String,
    val email: String,
    val rol: String,
    val negocioId: String? = null,
    val tenantId: String
)

@Entity(tableName = "shifts")
data class Shift(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val businessId: String,
    val cashierId: String,
    val tenantId: String,
    val openTimestamp: Long = System.currentTimeMillis(),
    val closeTimestamp: Long? = null,
    val initialCash: Double = 0.0,
    val totalSales: Double = 0.0,
    val totalExpenses: Double = 0.0,
    val totalCancellations: Double = 0.0,
    val totalCash: Double = 0.0,
    val totalCard: Double = 0.0,
    val isSynced: Boolean = false,
    val comment: String? = null
)

@Entity(tableName = "sale_notes")
data class SaleNote(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val shiftId: String,
    val businessId: String,
    val cashierId: String,
    val tenantId: String,
    val customerName: String? = null,
    val totalAmount: Double,
    val paymentMethod: String, // "Efectivo" o "Tarjeta"
    val timestamp: Long = System.currentTimeMillis(),
    val isSynced: Boolean = false,
    val isCancelled: Boolean = false
)

@Entity(
    tableName = "sale_details",
    foreignKeys = [
        ForeignKey(
            entity = SaleNote::class,
            parentColumns = ["id"],
            childColumns = ["noteId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("noteId")]
)
data class SaleDetail(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val noteId: String,
    val productName: String,
    val quantity: Int,
    val unitPrice: Double, // Estampado
    val subtotal: Double   // Estampado
)

@Entity(tableName = "expenses")
data class Expense(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val shiftId: String,
    val cashierId: String,
    val businessId: String,
    val tenantId: String,
    val description: String,
    val amount: Double,
    val photoPath: String? = null,
    val timestamp: Long = System.currentTimeMillis(),
    val isSynced: Boolean = false
)

@Entity(tableName = "cancellations")
data class Cancellation(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val noteId: String,
    val shiftId: String,
    val cashierId: String,
    val reason: String,
    val photoPath: String? = null,
    val timestamp: Long = System.currentTimeMillis(),
    val isSynced: Boolean = false
)

@Entity(tableName = "app_metadata")
data class AppMetadata(
    @PrimaryKey val id: Int = 1,
    val lastLoginTimestamp: Long,
    val lastMasterSyncTimestamp: Long,
    val lastPruneTimestamp: Long = 0L,
    val isLicenseValid: Boolean = true
)

// --- DAOs ---

@Dao
interface UserDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: User)
    @Query("SELECT * FROM users LIMIT 1")
    suspend fun getCurrentUser(): User?
    @Query("DELETE FROM users")
    suspend fun clearUser()
}

@Dao
interface ShiftDao {
    @Insert
    suspend fun openShift(shift: Shift)
    @Update
    suspend fun updateShift(shift: Shift)
    @Query("SELECT * FROM shifts WHERE businessId = :businessId AND closeTimestamp IS NULL LIMIT 1")
    suspend fun getActiveShift(businessId: String): Shift?
    @Query("SELECT * FROM shifts WHERE isSynced = 0")
    suspend fun getPendingShifts(): List<Shift>
    @Query("DELETE FROM shifts WHERE closeTimestamp < :threshold AND isSynced = 1")
    suspend fun pruneSyncedShifts(threshold: Long)
}

@Dao
interface SaleDao {
    @Insert
    suspend fun insertNote(note: SaleNote)
    @Insert
    suspend fun insertDetails(details: List<SaleDetail>)
    @Update
    suspend fun updateNote(note: SaleNote)
    @Query("SELECT * FROM sale_notes WHERE shiftId = :shiftId")
    suspend fun getNotesByShift(shiftId: String): List<SaleNote>
    @Query("SELECT * FROM sale_details WHERE noteId = :noteId")
    suspend fun getDetailsByNote(noteId: String): List<SaleDetail>
    @Query("SELECT * FROM sale_notes WHERE isSynced = 0")
    suspend fun getPendingNotes(): List<SaleNote>
    @Query("DELETE FROM sale_notes WHERE timestamp < :threshold AND isSynced = 1")
    suspend fun pruneSyncedSales(threshold: Long)
}

@Dao
interface ExpenseDao {
    @Insert
    suspend fun insertExpense(expense: Expense)
    @Update
    suspend fun updateExpense(expense: Expense)
    @Query("SELECT * FROM expenses WHERE shiftId = :shiftId")
    suspend fun getExpensesByShift(shiftId: String): List<Expense>
    @Query("SELECT * FROM expenses WHERE isSynced = 0")
    suspend fun getPendingExpenses(): List<Expense>
    @Query("DELETE FROM expenses WHERE timestamp < :threshold AND isSynced = 1")
    suspend fun pruneSyncedExpenses(threshold: Long)
}

@Dao
interface CancellationDao {
    @Insert
    suspend fun insertCancellation(cancellation: Cancellation)
    @Query("SELECT * FROM cancellations WHERE isSynced = 0")
    suspend fun getPendingCancellations(): List<Cancellation>
}

@Dao
interface MetadataDao {
    @Query("SELECT * FROM app_metadata WHERE id = 1")
    suspend fun getMetadata(): AppMetadata?
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun updateMetadata(metadata: AppMetadata)
}

@Database(
    entities = [User::class, Shift::class, SaleNote::class, SaleDetail::class, Expense::class, Cancellation::class, AppMetadata::class],
    version = 9,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    abstract fun shiftDao(): ShiftDao
    abstract fun saleDao(): SaleDao
    abstract fun expenseDao(): ExpenseDao
    abstract fun cancellationDao(): CancellationDao
    abstract fun metadataDao(): MetadataDao
}
