package com.tacoos.poc.presentation.layout

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import kotlinx.coroutines.delay
import com.tacoos.poc.R

/**
 * Componente que muestra un carrusel de imágenes con cambio automático.
 * Utiliza un [HorizontalPager] para deslizar entre las imágenes de recursos locales.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun AutoImageSlider() {
    // Estado del pager con 4 páginas iniciales
    val pagerState = rememberPagerState(pageCount = { 4 })

    // Efecto para cambiar automáticamente cada 3 segundos
    // LaunchedEffect se cancela automáticamente si el usuario cambia la página manualmente,
    // evitando la acumulación de corrutinas (fugas de memoria).
    LaunchedEffect(pagerState.currentPage) {
        delay(3000) // Espera 3 segundos
        val nextPage = (pagerState.currentPage + 1) % pagerState.pageCount
        pagerState.animateScrollToPage(nextPage)
    }

    HorizontalPager(
        state = pagerState,
        modifier = Modifier.fillMaxSize()
    ) { page ->
        val imageRes = when (page) {
            0 -> R.drawable.slider1
            1 -> R.drawable.slider2
            2 -> R.drawable.slider3
            else -> R.drawable.slider4
        }
        Image(
            painter = painterResource(id = imageRes),
            contentDescription = "Imagen $page",
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )
    }
}
