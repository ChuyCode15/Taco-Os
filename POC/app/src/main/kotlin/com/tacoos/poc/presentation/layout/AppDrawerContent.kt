package com.tacoos.poc.presentation.layout

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import coil.compose.AsyncImage
import com.tacoos.poc.presentation.theme.PrimaryNavy
import com.tacoos.poc.presentation.uiState.auth.AuthUiState

/**
 * Componente que representa el contenido del menú lateral (Drawer) de la aplicación.
 * Muestra información del usuario, opciones de navegación y ajustes de tema.
 * 
 * @param uiState Estado de autenticación que contiene info del usuario (foto, nombre, rol).
 * @param isDarkMode Indica si el modo oscuro está activo.
 * @param onThemeChange Callback para cambiar el tema (oscuro/claro).
 * @param navController Controlador de navegación para redirigir a otras pantallas.
 * @param onClose Callback para cerrar el menú lateral.
 */
@Composable
fun AppDrawerContent(
    uiState: AuthUiState,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit,
    navController: NavController,
    onClose: () -> Unit
) {
    ModalDrawerSheet(modifier = Modifier.width(300.dp)) {
        Column(modifier = Modifier.fillMaxSize()) {
            // HEADER: Foto ovalada y nombre del usuario obtenido de Google
            Box(modifier = Modifier.fillMaxWidth().background(Color(0xFF0D47A1)).padding(top = 48.dp, start = 24.dp, end = 24.dp, bottom = 24.dp)) {
                Column {
                    Surface(
                        modifier = Modifier.size(width = 80.dp, height = 65.dp).clip(RoundedCornerShape(30.dp)), // Forma ovalada
                        color = Color.White.copy(alpha = 0.2f)
                    ) {
                        if (uiState.fotoUrl != null) {
                            AsyncImage(
                                model = uiState.fotoUrl,
                                contentDescription = "Foto de perfil",
                                modifier = Modifier.fillMaxSize(),
                                contentScale = ContentScale.Crop
                            )
                        } else {
                            Icon(
                                imageVector = Icons.Default.Person,
                                contentDescription = null,
                                modifier = Modifier.padding(12.dp),
                                tint = Color.White
                            )
                        }
                    }
                    Spacer(Modifier.height(16.dp))

                    // Mostramos el nombre directamente desde el estado
                    Text(
                        text = uiState.nickname.ifEmpty { "Usuario Taco-Os" },
                        color = Color.White,
                        fontWeight = FontWeight.Black,
                        fontSize = 18.sp
                    )

                    Text(
                        text = uiState.rol.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() },
                        color = Color.White.copy(alpha = 0.7f),
                        fontSize = 14.sp
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            // OPCIONES dinámicas según el Rol
            DrawerOptions(rol = uiState.rol, navController = navController, onClose = onClose)

            Divider(modifier = Modifier.padding(vertical = 12.dp, horizontal = 16.dp).alpha(0.3f))

            // MODO OSCURO
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(if(isDarkMode) Icons.Default.DarkMode else Icons.Default.LightMode, null, tint = Color.Gray)
                    Spacer(Modifier.width(12.dp))
                    Text("Modo Oscuro", fontWeight = FontWeight.Bold)
                }
                Switch(checked = isDarkMode, onCheckedChange = onThemeChange)
            }

            Spacer(modifier = Modifier.weight(1f))

            // CERRAR SESIÓN
            Text(
                "CERRAR SESIÓN",
                modifier = Modifier
                    .padding(24.dp)
                    .clickable {
                        onClose()
                        navController.navigate("login") { popUpTo(0) }
                    },
                color = Color.Red,
                fontWeight = FontWeight.Black,
                letterSpacing = 1.sp
            )
        }
    }
}

/**
 * Renderiza las opciones del menú lateral basándose en el rol del usuario.
 * 
 * @param rol Rol del usuario (ej: "dueño", "cajero").
 * @param navController Controlador de navegación.
 * @param onClose Callback para cerrar el menú lateral tras una selección.
 */
@Composable
fun DrawerOptions(rol: String, navController: NavController, onClose: () -> Unit) {
    val isOwner = rol.lowercase() == "dueño"

    DrawerItem(Icons.Default.Dashboard, "Dashboard") { onClose(); navController.navigate("dashboard") }
    DrawerItem(Icons.Default.PointOfSale, "Ventas") { onClose(); navController.navigate("sales") }
    
    if (isOwner) {
        DrawerItem(Icons.Default.BarChart, "Reportes") { onClose(); navController.navigate("reports") }
        DrawerItem(Icons.Default.Groups, "Mi Equipo") { onClose(); navController.navigate("cashiers") }
        DrawerItem(Icons.Default.Fastfood, "Mis Productos") { onClose(); navController.navigate("products") }
    } else {
        DrawerItem(Icons.Default.History, "Mis Turnos") { onClose(); navController.navigate("shifts") }
    }
    
    DrawerItem(Icons.Default.Settings, "Ajustes") { onClose(); navController.navigate("settings") }
}

/**
 * Componente individual para un elemento de navegación dentro del Drawer.
 * 
 * @param icon Icono a mostrar.
 * @param label Texto de la opción.
 * @param onClick Acción al pulsar el elemento.
 */
@Composable
fun DrawerItem(icon: ImageVector, label: String, onClick: () -> Unit) {
    NavigationDrawerItem(
        label = { Text(label, fontWeight = FontWeight.Bold) },
        selected = false,
        onClick = onClick,
        icon = { Icon(icon, null) },
        modifier = Modifier.padding(horizontal = 12.dp)
    )
}

/**
 * Previsualización del menú lateral.
 */
@Preview(showBackground = true, showSystemUi = true)
@Composable
fun AppDrawerContentPreview() {
    AppDrawerContent(
        uiState = AuthUiState(),
        isDarkMode = false,
        onThemeChange = {},
        navController = NavController(LocalContext.current),
        onClose = {}
    )
}
