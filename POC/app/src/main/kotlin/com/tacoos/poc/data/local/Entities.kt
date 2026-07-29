package com.tacoos.poc.data.local

import androidx.room.*

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
 * Entidad Corte: La unidad maestra de auditoría para un turno de caja.
 * Inmutable tras el cierre.
 */
@Entity(tableName = "cortes")
data class Corte(
    @PrimaryKey val id: String, // UUID
    val tenantId: String,
    val cashierId: String,
    val openedAt: Long = System.currentTimeMillis(),
    val closedAt: Long? = null,
    val initialCash: Double = 0.0,
    val totalSalesAmount: Double = 0.0,
    val totalSalesCash: Double = 0.0,
    val totalSalesCard: Double = 0.0,
    val totalExpensesAmount: Double = 0.0,
    val expectedCash: Double = 0.0,
    val realCashCounted: Double? = null,
    val difference: Double = 0.0,
    val status: String = "OPEN", // OPEN, CLOSED
    val isSynced: Boolean = false
)

/**
 * Entidad SaleNote: Representa la cabecera de una nota de venta.
 */
@Entity(
    tableName = "sale_notes",
    foreignKeys = [
        ForeignKey(
            entity = Corte::class,
            parentColumns = ["id"],
            childColumns = ["corteId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("corteId")]
)
data class SaleNote(
    @PrimaryKey val id: String, // UUID
    val folio: Long = 0,
    val tenantId: String,
    val corteId: String,
    val totalProducts: Int = 0,
    val totalAmount: Double = 0.0,
    val paymentMethod: String = "CASH", // CASH, CARD
    val voucherPath: String? = null,
    val productsJson: String = "", // Snapshot de auditoría
    val timestamp: Long = System.currentTimeMillis(),
    val status: String = "ACTIVE", // ACTIVE, CANCELLED
    val isSynced: Boolean = false
)

/**
 * Entidad SaleDetail: Líneas de detalle inmutables de una nota.
 */
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
    @PrimaryKey val id: String, // UUID
    val noteId: String,
    val productName: String,
    val quantity: Int,
    val unitPrice: Double,
    val totalPrice: Double, // Persistido: quantity * unitPrice
    val status: String = "ACTIVE"
)

/**
 * Entidad Sale: Registro legacy (Mantenido por compatibilidad hasta migración total).
 */
@Entity(tableName = "sales")
data class Sale(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val amount: Double,
    val userId: String = "",
    val productsJson: String = "",
    val method: String = "Efectivo",
    val status: String = "ACTIVE",
    val imagePath: String? = null, 
    val timestamp: Long = System.currentTimeMillis(),
    val isSynced: Boolean = false,
    val negocioId: String
)

/**
 * Entidad Expense: Actualizada para vincularse a un Corte.
 */
@Entity(tableName = "expenses")
data class Expense(
    @PrimaryKey val id: String,
    val detail: String,
    val amount: Double,
    val cashier: String,
    val timestamp: Long = System.currentTimeMillis(),
    val imagePath: String? = null,
    val isSynced: Boolean = false,
    val negocioId: String,
    val corteId: String? = null // FK opcional para transición
)

@Entity(tableName = "products")
data class Product(
    @PrimaryKey val id: String,
    val name: String,
    val price: Double,
    val category: String,
    val imagePath: String? = null,
    val negocioId: String,
    val isSynced: Boolean = false
)

@Dao
interface CorteDao {
    @Query("SELECT * FROM cortes WHERE status = 'OPEN' AND tenantId = :negocioId LIMIT 1")
    suspend fun getActiveCorte(negocioId: String): Corte?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCorte(corte: Corte)

    @Update
    suspend fun updateCorte(corte: Corte)

    @Query("SELECT * FROM cortes WHERE id = :id")
    suspend fun getCorteById(id: String): Corte?
}

@Dao
interface SaleNoteDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertNote(note: SaleNote)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertDetails(details: List<SaleDetail>)

    @Query("SELECT * FROM sale_notes WHERE corteId = :corteId")
    suspend fun getNotesByCorte(corteId: String): List<SaleNote>
}

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
interface ProductDao {
    @Query("SELECT * FROM products WHERE negocioId = :negocioId ORDER BY name ASC")
    suspend fun getProducts(negocioId: String): List<Product>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProduct(product: Product)

    @Update
    suspend fun updateProduct(product: Product)

    @Delete
    suspend fun deleteProduct(product: Product)
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

@Database(
    entities = [
        Sale::class, User::class, Business::class, AppMetadata::class, 
        Expense::class, Product::class, Corte::class, SaleNote::class, SaleDetail::class
    ], 
    version = 8, 
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun saleDao(): SaleDao
    abstract fun expenseDao(): ExpenseDao
    abstract fun productDao(): ProductDao
    abstract fun userDao(): UserDao
    abstract fun businessDao(): BusinessDao
    abstract fun metadataDao(): MetadataDao
    abstract fun corteDao(): CorteDao
    abstract fun saleNoteDao(): SaleNoteDao
}
