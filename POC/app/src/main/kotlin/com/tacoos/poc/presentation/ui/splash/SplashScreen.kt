package com.tacoos.poc.presentation.ui.splash

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.tacoos.poc.presentation.viewmodel.auth.AuthViewModel
import kotlinx.coroutines.delay
import androidx.compose.ui.tooling.preview.Preview

/**
 * Pantalla de bienvenida (Splash Screen) con animaciones de entrada.
 * Verifica el estado de autenticación al finalizar.
 *
 * @param onSplashFinished Función que se ejecuta al terminar el splash, pasando si el usuario está autenticado.
 * @param viewModel ViewModel para obtener el estado de autenticación.
 */
@Composable
fun SplashScreen(
    onSplashFinished: (isAuthenticated: Boolean) -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    SplashContent(
        isAuthenticated = uiState.isAuthenticated,
        onSplashFinished = onSplashFinished
    )
}

/**
 * Contenido visual y animado de la pantalla de bienvenida.
 *
 * @param isAuthenticated Estado de autenticación actual.
 * @param onSplashFinished Callback al finalizar las animaciones.
 */
@Composable
fun SplashContent(
    isAuthenticated: Boolean,
    onSplashFinished: (Boolean) -> Unit
) {
    // Estado para iniciar la animación al cargar la pantalla
    var startAnimation by remember { mutableStateOf(false) }

    // Animación de opacidad (fade in)
    val alphaAnim by animateFloatAsState(
        targetValue = if (startAnimation) 1f else 0f,
        animationSpec = tween(
            durationMillis = 1000,
            easing = FastOutSlowInEasing
        ),
        label = "alphaAnimation"
    )

    // Animación de escala (zoom in)
    val scaleAnim by animateFloatAsState(
        targetValue = if (startAnimation) 1f else 0f,
        animationSpec = tween(
            durationMillis = 900,
            easing = FastOutSlowInEasing
        ),
        label = "scaleAnimation"
    )

    // Efecto lanzado al iniciar la pantalla
    LaunchedEffect(key1 = true) {
        startAnimation = true
        delay(3000)
        onSplashFinished(isAuthenticated)
    }

    // Contenedor principal con gradiente azul de fondo
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF0D47A1),
                        Color(0xFF0D47A1)
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        // Contenido central con animaciones aplicadas
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier
                .scale(scaleAnim)
                .alpha(alphaAnim)
        ) {

            Spacer(modifier = Modifier.height(24.dp))

            // Título principal de la aplicación
            Text(
                text = "TACOOS",
                fontSize = 34.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFFE3F2FD),
                letterSpacing = 1.5.sp
            )

            Spacer(modifier = Modifier.height(6.dp))

            // Subtítulo descriptivo
            Text(
                text = "Sistema de punto de venta y gestión",
                fontSize = 14.sp,
                color = Color(0xff94A3B8),
                fontWeight = FontWeight.Medium
            )
        }

        // Texto inferior con versión y créditos
        Text(
            text = "v2.0.0 ° Powered by Taco'Os",
            fontSize = 12.sp,
            color = Color(0xFFE3F2FD),
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 32.dp)
        )
    }
}

/**
 * Previsualización de la pantalla de bienvenida (Splash).
 */
@Preview(showBackground = true, apiLevel = 33)
@Composable
fun SplashScreenPreview() {
    SplashContent(isAuthenticated = false, onSplashFinished = {})
}
