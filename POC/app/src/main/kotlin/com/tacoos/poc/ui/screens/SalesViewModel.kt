package com.tacoos.poc.ui.screens

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.google.gson.Gson
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.TacoRepository
import kotlinx.coroutines.launch

class SalesViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    private val repository = TacoRepository(app.api, app.database)
    private val gson = Gson()

    fun saveSale(amount: Double, products: List<POSItem>) {
        viewModelScope.launch {
            val user = repository.getCurrentUser()
            val negocioId = user?.negocioId ?: "DEFAULT_BIZ"
            val userId = user?.id ?: ""
            
            // Serializamos los productos para persistencia
            val productsJson = gson.toJson(products)
            
            repository.registerSale(
                amount = amount,
                negocioId = negocioId,
                userId = userId,
                productsJson = productsJson
            )
            // La venta queda guardada en SQLite con isSynced = false
            // El SyncWorker la subirá al servidor automáticamente
        }
    }
}
