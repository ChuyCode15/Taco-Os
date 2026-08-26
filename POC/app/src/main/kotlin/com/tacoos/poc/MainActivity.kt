package com.tacoos.poc

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.*
import com.tacoos.poc.presentation.navigation.AppNavGraph
import com.tacoos.poc.presentation.theme.TacoOsTheme
import dagger.hilt.android.AndroidEntryPoint

/**
 * Actividad principal de la aplicación que sirve como punto de entrada para la UI.
 * Utiliza Hilt para la inyección de dependencias y Jetpack Compose para la interfaz.
 */
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    /**
     * Inicializa la actividad y configura el contenido de Compose.
     * @param savedInstanceState Estado guardado de la instancia si existe.
     */
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            var isDarkMode by remember { mutableStateOf(false) }
            TacoOsTheme(darkTheme = isDarkMode) {
                AppNavGraph(
                    isDarkMode = isDarkMode,
                    onThemeChange = { isDarkMode = it }
                )
            }
        }
    }
}
