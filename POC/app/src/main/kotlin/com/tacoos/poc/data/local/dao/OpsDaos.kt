package com.tacoos.poc.data.local.dao

import androidx.room.*
import com.tacoos.poc.data.local.*

@Dao
interface SaleDao {
    @Query("SELECT * FROM sales WHERE shiftId = :shiftId ORDER BY timestamp DESC")
    suspend fun getSalesByShift(shiftId: Long): List<Sale>

    @Insert
    suspend fun insertSale(sale: Sale): Long

    @Update
    suspend fun updateSale(sale: Sale)

    @Query("SELECT * FROM sales WHERE id = :saleId")
    suspend fun getSaleById(saleId: Long): Sale?

    @Query("SELECT SUM(amount) FROM sales WHERE shiftId = :shiftId AND status = 'ACTIVE'")
    suspend fun getShiftTotalSales(shiftId: Long): Double?

    @Query("SELECT SUM(amount) FROM sales WHERE shiftId = :shiftId AND status = 'ACTIVE' AND paymentMethod = 'efectivo'")
    suspend fun getShiftCashSales(shiftId: Long): Double?

    @Query("SELECT SUM(amount) FROM sales WHERE shiftId = :shiftId AND status = 'ACTIVE' AND paymentMethod = 'tarjeta'")
    suspend fun getShiftCardSales(shiftId: Long): Double?

    @Query("SELECT COUNT(*) FROM sales WHERE shiftId = :shiftId AND status = 'ACTIVE'")
    suspend fun getShiftSalesCount(shiftId: Long): Int
}

@Dao
interface ShiftDao {
    @Insert
    suspend fun insertShift(shift: Shift): Long

    @Update
    suspend fun updateShift(shift: Shift)

    @Query("SELECT * FROM shifts WHERE userId = :userId AND isOpen = 1 LIMIT 1")
    suspend fun getActiveShift(userId: String): Shift?

    @Query("SELECT * FROM shifts WHERE id = :shiftId")
    suspend fun getShiftById(shiftId: Long): Shift?

    @Query("SELECT * FROM shifts WHERE negocioId = :negocioId AND status = 'OPEN' LIMIT 1")
    suspend fun getActiveShiftByBusiness(negocioId: String): Shift?
}

@Dao
interface ExpenseDao {
    @Insert
    suspend fun insertExpense(expense: Expense): Long

    @Query("SELECT SUM(amount) FROM expenses WHERE shiftId = :shiftId")
    suspend fun getShiftTotalExpenses(shiftId: Long): Double?
}

@Dao
interface ProductDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProducts(products: List<Product>)

    @Query("SELECT * FROM products_local WHERE negocioId = :negocioId AND (categoria = :categoria OR category = :categoria)")
    suspend fun getProductsByCategory(negocioId: String, categoria: String): List<Product>

    @Query("SELECT * FROM products_local WHERE negocioId = :negocioId")
    suspend fun getProducts(negocioId: String): List<Product>

    @Query("DELETE FROM products_local WHERE negocioId = :negocioId")
    suspend fun clearProducts(negocioId: String)
}

@Dao
interface MetadataDao {
    @Query("SELECT * FROM app_metadata WHERE id = 1")
    suspend fun getMetadata(): AppMetadata?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun updateMetadata(metadata: AppMetadata)
}
