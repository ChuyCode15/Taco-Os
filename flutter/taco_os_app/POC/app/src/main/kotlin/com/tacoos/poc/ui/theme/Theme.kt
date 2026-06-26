package com.tacoos.poc.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

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

@Composable
fun TacoOsTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    // Para el POS mantendremos LightTheme como base de claridad
    MaterialTheme(
        colorScheme = LightColorScheme,
        typography = Typography(),
        content = content
    )
}
