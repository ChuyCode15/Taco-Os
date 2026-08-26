package com.tacoos.poc.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.tacoos.poc.domain.model.TacoEntity
import kotlinx.coroutines.flow.Flow

/**
 * Interfaz de Acceso a Datos (DAO) para realizar operaciones CRUD en la tabla de tacos.
 */
@Dao
interface TacoDao {
    /**
     * Recupera todos los tacos almacenados en la base de datos.
     * @return Un flujo [Flow] que emite la lista de entidades de taco.
     */
    @Query("SELECT * FROM tacos")
    fun getAllTacos(): Flow<List<TacoEntity>>

    /**
     * Inserta un taco en la base de datos, reemplazándolo si ya existe.
     * @param taco Entidad de taco a insertar.
     */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTaco(taco: TacoEntity)
}
