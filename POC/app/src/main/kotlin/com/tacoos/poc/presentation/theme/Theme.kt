package com.tacoos.poc.presentation.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

/**
 * Configuración del esquema de colores para el tema claro.
 */
private val LightColorScheme = lightColorScheme(
    primary = ActionBlue,
    onPrimary = Color.White,
    secondary = PrimaryNavy,
    onSecondary = Color.White,
    tertiary = SuccessGreen,
    background = BackgroundWhite,
    surface = SurfaceCard,
    onBackground = TextPrimary,
    onSurface = TextPrimary,
    error = ErrorRed
)

/**
 * Configuración del esquema de colores para el tema oscuro.
 */
private val DarkColorScheme = darkColorScheme(
    primary = DarkActionBlue,
    onPrimary = Color.White,
    secondary = PrimaryNavy,
    onSecondary = Color.White,
    tertiary = SuccessGreen,
    background = DarkBackground,
    surface = DarkSurface,
    onBackground = DarkTextPrimary,
    onSurface = DarkTextPrimary,
    error = ErrorRed
)

/**
 * Tema principal de la aplicación Taco-Os.
 * Proporciona el esquema de colores y tipografía global.
 * 
 * @param darkTheme Indica si se debe aplicar el tema oscuro. Por defecto detecta el sistema.
 * @param content Contenido composable que heredará el tema.
 */
@Composable
fun TacoOsTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    
    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography(),
        content = content
    )
}
