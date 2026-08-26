package com.tacoos.poc.domain.model

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Modelo de datos que representa un taco persistido localmente mediante Room.
 * @property id Identificador único autogenerado.
 * @property name Nombre descriptivo del taco.
 * @property price Precio unitario del producto.
 * @property ingredients Lista de ingredientes asociados (serializada).
 */
@Entity(tableName = "tacos")
data class TacoEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val name: String,
    val price: Double,
    val ingredients: String
)
