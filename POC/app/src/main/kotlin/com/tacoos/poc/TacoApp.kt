package com.tacoos.poc

import android.app.Application
import com.tacoos.poc.data.TacoRepository
import dagger.hilt.android.HiltAndroidApp
import javax.inject.Inject

/**
 * Clase base de la aplicación necesaria para la inicialización de Hilt.
 * Actúa como el contenedor principal del grafo de dependencias de la aplicación.
 */
@HiltAndroidApp
class TacoApp : Application() {
    @Inject
    lateinit var repository: TacoRepository
}
