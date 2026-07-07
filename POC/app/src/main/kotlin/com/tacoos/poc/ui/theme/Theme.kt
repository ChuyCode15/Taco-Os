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
