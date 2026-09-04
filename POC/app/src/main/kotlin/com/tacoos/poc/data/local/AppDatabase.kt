package com.tacoos.poc.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.tacoos.poc.data.local.dao.*
import com.tacoos.poc.domain.model.TacoEntity

/**
 * Base de datos principal de la aplicación implementada con Room.
 * Gestiona la persistencia local de los datos de la aplicación.
 */
@Database(
    entities = [
        TacoEntity::class,
        UserEntity::class,
        Business::class,
        Shift::class,
        Sale::class,
        Expense::class,
        Product::class,
        AppMetadata::class
    ],
    version = 2, // Incrementar versión por cambios en esquema
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun tacoDao(): TacoDao
    abstract fun saleDao(): SaleDao
    abstract fun shiftDao(): ShiftDao
    abstract fun expenseDao(): ExpenseDao
    abstract fun productDao(): ProductDao
    abstract fun metadataDao(): MetadataDao
}
