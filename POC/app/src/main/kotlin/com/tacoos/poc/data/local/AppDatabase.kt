package com.tacoos.poc.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.tacoos.poc.data.local.dao.TacoDao
import com.tacoos.poc.domain.model.TacoEntity

/**
 * Base de datos principal de la aplicación implementada con Room.
 * Gestiona la persistencia local de los datos de la aplicación.
 */
@Database(
    entities = [TacoEntity::class], // Entidades relacionadas con la base de datos
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    /**
     * Proporciona el DAO para realizar operaciones sobre la tabla de tacos.
     * @return Instancia de [TacoDao].
     */
    abstract fun tacoDao(): TacoDao
}
