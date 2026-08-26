package com.tacoos.poc

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

/**
 * Clase base de la aplicación necesaria para la inicialización de Hilt.
 * Actúa como el contenedor principal del grafo de dependencias de la aplicación.
 */
@HiltAndroidApp
class TacoApp : Application()
