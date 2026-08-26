package com.tacoos.poc.presentation.uiState.business

/**
 * Estado de la interfaz de usuario para el registro y gestión de un negocio.
 *
 * @property nombre Nombre comercial del negocio.
 * @property domicilio Dirección física del negocio.
 * @property telefono Número telefónico de contacto.
 * @property giro Categoría o tipo de negocio.
 * @property empleados Número de empleados del establecimiento.
 * @property horarioCierre Hora programada para el cierre del negocio.
 * @property isLoading Indica si hay una operación de registro o carga en proceso.
 * @property isSuccess Indica si la operación fue exitosa.
 * @property successMessage Mensaje de éxito para el usuario.
 * @property errorMessage Mensaje de error detallado en caso de falla.
 */
data class BusinessUiState(
    val nombre: String = "",
    val domicilio: String = "",
    val telefono: String = "",
    val giro: String = "",
    val empleados: String = "1",
    val horarioCierre: String = "22:00",
    val isLoading: Boolean = false,
    val isSuccess: Boolean = false,
    val successMessage: String? = null,
    val errorMessage: String? = null
)
