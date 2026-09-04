package com.tacoos.poc.presentation.ui.Administrador

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.R
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.compose.rememberNavController
import com.tacoos.poc.presentation.layout.AppDrawerContent
import com.tacoos.poc.presentation.navigation.Routes
import com.tacoos.poc.presentation.theme.ActionBlue
import com.tacoos.poc.presentation.theme.PrimaryNavy
import com.tacoos.poc.presentation.uiState.auth.AuthUiState
import com.tacoos.poc.presentation.viewmodel.auth.AuthViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Pantalla principal de la aplicación (Dashboard) que se muestra tras el inicio de sesión.
 * Adapta sus opciones y apariencia según el rol del usuario (Administrador o Cajero).
 *
 * @param navController Controlador de navegación para redirigir a otras secciones.
 * @param isDarkMode Indica si el modo oscuro está habilitado.
 * @param onThemeChange Callback para alternar entre el tema claro y oscuro.
 * @param viewModel ViewModel que proporciona el estado de autenticación y datos del usuario.
 */
@Composable
fun DashboardScreen(
    navController: NavController,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    DashboardContent(
        uiState = uiState,
        navController = navController,
        isDarkMode = isDarkMode,
        onThemeChange = onThemeChange
    )
}

/**
 * Contenido visual de la pantalla Dashboard.
 *
 * @param uiState Estado actual de la autenticación y datos del usuario.
 * @param navController Controlador de navegación.
 * @param isDarkMode Indica si el modo oscuro está activo.
 * @param onThemeChange Callback para cambiar el tema.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardContent(
    uiState: AuthUiState,
    navController: NavController,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit
) {
    val scope = rememberCoroutineScope()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            AppDrawerContent(
                uiState = uiState,
                isDarkMode = isDarkMode,
                onThemeChange = onThemeChange,
                navController = navController,
                onClose = { scope.launch { drawerState.close() } }
            )
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        val title = if (uiState.rol.lowercase() == "dueño") "ADMINISTRADOR" else "CAJERO"
                        Text(title, fontWeight = FontWeight.Black, letterSpacing = 1.sp, fontSize = 18.sp)
                    },
                    navigationIcon = {
                        IconButton(onClick = { scope.launch { drawerState.open() } }) {
                            Icon(Icons.Default.Menu, contentDescription = "Menú")
                        }
                    },
                    actions = {
                        IconButton(onClick = { /* Notificaciones */ }) {
                            Icon(Icons.Default.Notifications, null)
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
                )
            }
        ) { padding ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Banner / Pager (Visible para ambos)
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp)
                        .padding(20.dp)
                        .clip(RoundedCornerShape(32.dp))
                        .background(
                            Brush.linearGradient(
                                colors = if(isDarkMode) listOf(Color(0xFF2C2C2E), Color(0xFF1C1C1E)) else listOf(PrimaryNavy, ActionBlue)
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    val bannerImages = remember {
                        listOf(
                            R.drawable.slider1,
                            R.drawable.slider2,
                            R.drawable.slider3,
                            R.drawable.slider4
                        )
                    }
                    val pagerState = rememberPagerState(pageCount = { 10000 })

                    LaunchedEffect(Unit) {
                        while (true) {
                            delay(3000)
                            pagerState.animateScrollToPage(pagerState.currentPage + 1)
                        }
                    }

                    HorizontalPager(
                        state = pagerState,
                        modifier = Modifier.fillMaxSize()
                    ) { page ->
                        val index = page % bannerImages.size
                        Image(
                            painter = painterResource(id = bannerImages[index]),
                            contentDescription = null,
                            modifier = Modifier.fillMaxSize(),
                            contentScale = ContentScale.Crop
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                // Botones dinámicos según el Rol
                DashboardButtons(rol = uiState.rol, navController = navController)
            }
        }
    }
}

/**
 * Muestra el conjunto de botones de acción dinámicos en el Dashboard basándose en el rol del usuario.
 *
 * @param rol El rol del usuario actual (por ejemplo, "dueño" o "cajero").
 * @param navController Controlador de navegación para gestionar los clics en los botones.
 */
@Composable
fun DashboardButtons(rol: String, navController: NavController) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        // Botón común
        AdminButton(title = "VENTAS", icon = Icons.Default.ShoppingCart, onClick = { navController.navigate("sales") })
        Spacer(modifier = Modifier.height(16.dp))
        
        // Botones exclusivos de Administrador (Dueño)
        if (rol.lowercase() == "dueño") {
            AdminButton(title = "REPORTES", icon = Icons.Default.List, onClick = { navController.navigate("reports") })
            Spacer(modifier = Modifier.height(16.dp))
            AdminButton(title = "CAJEROS", icon = Icons.Default.Person, onClick = { navController.navigate(Routes.CASHIERS) })
        } else {
            // Botones exclusivos de Cajero
            AdminButton(title = "MIS TURNOS", icon = Icons.Default.History, onClick = { navController.navigate("shifts") })
        }
    }
}

/**
 * Un botón de acción estilizado para el panel de administración/cajero.
 *
 * @param title Texto que se mostrará en el botón.
 * @param icon Icono que acompañará al texto.
 * @param onClick Acción que se ejecutará al pulsar el botón.
 */
@Composable
fun AdminButton(title: String, icon: ImageVector, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(0.85f).height(70.dp),
        shape = RoundedCornerShape(22.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer,
            contentColor = MaterialTheme.colorScheme.onSecondaryContainer
        )
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
            Icon(icon, null)
            Spacer(Modifier.width(16.dp))
            Text(title, fontWeight = FontWeight.Black, fontSize = 16.sp)
            Spacer(Modifier.weight(1f))
            Icon(Icons.Default.ArrowForward, null)
        }
    }
}


/**
 * Previsualización del Dashboard.
 */
@Preview(showBackground = true, showSystemUi = true, name = "Administrador")
@Composable
fun DashboardScreenPreview() {
    DashboardContent(
        uiState = AuthUiState(rol = "dueño", nickname = "Faner"),
        navController = rememberNavController(),
        isDarkMode = false,
        onThemeChange = {}
    )
}

@Preview(showBackground = true, showSystemUi = true, name = "Cajero")
@Composable
fun DashboardCajeroPreview() {
    DashboardContent(
        uiState = AuthUiState(rol = "cajero", nickname = "Jesus"),
        navController = rememberNavController(),
        isDarkMode = false,
        onThemeChange = {}
    )
}

