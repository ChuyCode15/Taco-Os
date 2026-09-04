package com.tacoos.poc.data.local

import androidx.room.*

@Entity(tableName = "users_local")
data class UserEntity(
    @PrimaryKey val id: String,
    val idGoogle: String,
    val nombre: String,
    val email: String,
    val rol: String,
    val negocioId: String? = null,
    val status: String = "ACTIVE"
)

@Entity(tableName = "business")
data class Business(
    @PrimaryKey val id: String,
    val nombre: String,
    val direccion: String,
    val telefono: String,
    val moneda: String = "MXN",
    val dineroBase: Double = 0.0,
    val plan: String = "FREE",
    val qrCode: String? = null
)

@Entity(tableName = "shifts")
data class Shift(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val userId: String = "",
    val negocioId: String,
    val cashierName: String = "",
    val initialAmount: Double = 0.0,
    val status: String = "OPEN",
    val openTimestamp: Long = System.currentTimeMillis(),
    val closeTimestamp: Long? = null,
    val fondoCambio: Double = 0.0,
    val timestampApertura: Long = System.currentTimeMillis(),
    val timestampCierre: Long? = null,
    val efectivoContado: Double? = null,
    val diferencia: Double? = null,
    val isSynced: Boolean = false,
    val isOpen: Boolean = true
)

@Entity(tableName = "sales")
data class Sale(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val shiftId: Long? = null,
    val amount: Double,
    val productsJson: String, 
    val paymentMethod: String, 
    val timestamp: Long = System.currentTimeMillis(),
    val isSynced: Boolean = false,
    val negocioId: String,
    val userId: String = "",
    val status: String = "ACTIVE",
    val cancelPhotoPath: String? = null,
    val cancelTimestamp: Long? = null
)

@Entity(tableName = "expenses")
data class Expense(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val shiftId: Long? = null,
    val detail: String = "",
    val description: String = "",
    val amount: Double,
    val timestamp: Long = System.currentTimeMillis(),
    val userId: String = "",
    val cashier: String = "",
    val negocioId: String,
    val isSynced: Boolean = false,
    val imagePath: String? = null
)

@Entity(tableName = "products_local")
data class Product(
    @PrimaryKey val id: String,
    val name: String = "",
    val nombre: String = "",
    val price: Double = 0.0,
    val precio: Double = 0.0,
    val category: String = "",
    val categoria: String = "",
    val imagePath: String? = null,
    val negocioId: String
)

@Entity(tableName = "app_metadata")
data class AppMetadata(
    @PrimaryKey val id: Int = 1,
    val lastLoginTimestamp: Long,
    val lastMasterSyncTimestamp: Long,
    val isLicenseValid: Boolean = true
)
