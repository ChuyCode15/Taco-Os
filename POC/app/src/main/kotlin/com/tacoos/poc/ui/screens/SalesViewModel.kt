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
    private val repository = app.repository
    private val gson = Gson()

    /**
     * Guarda una venta localmente e intenta sincronizarla.
     * @param amount Total de la venta.
     * @param products Lista de productos seleccionados.
     * @param method Método de pago (Efectivo, Tarjeta, etc).
     */
    fun saveSale(amount: Double, products: List<POSItem>, method: String = "Efectivo") {
        viewModelScope.launch {
            val user = repository.getCurrentUser()
            val negocioId = user?.negocioId ?: "DEFAULT_BIZ"
            val userId = user?.id ?: ""
            
            // 1. Buscamos si hay un turno activo para asociar la venta al corte de caja
            val activeShift = repository.getActiveShift(negocioId)
            
            // 2. Serializamos los productos para persistencia
            val productsJson = gson.toJson(products)
            
            // 3. Registramos la venta con todos los parámetros requeridos por el repositorio
            repository.registerSale(
                amount = amount,
                negocioId = negocioId,
                userId = userId,
                productsJson = productsJson,
                method = method,
                imagePath = null, // No hay imagen en este flujo por ahora
                shiftId = activeShift?.id // Asociamos al turno si existe
            )
        }
    }
}
