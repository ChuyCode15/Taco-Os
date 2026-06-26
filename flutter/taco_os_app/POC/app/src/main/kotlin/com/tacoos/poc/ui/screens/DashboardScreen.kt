package com.tacoos.poc.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import com.tacoos.poc.ui.theme.SuccessGreen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(navController: NavController) {
    var showMenu by remember { mutableStateOf(false) }
    val notificationCount = 12
    
    // Estados de seguridad y agilidad
    val isSessionValid = true // Simulado por ahora, vendría del Repository
    val isLicenseValid = true 

    Scaffold(
        topBar = {
            TopAppBar(
                title = { 
                    Column {
                        Text("Taco'Os Admin", fontWeight = FontWeight.Black, letterSpacing = (-1).sp)
                        Text(
                            text = if (isSessionValid) "Sesión Segura: 12h" else "Sesión Expirada",
                            style = MaterialTheme.typography.labelSmall,
                            color = if (isSessionValid) SuccessGreen else Color.Red
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = { showMenu = true }) {
                        Icon(Icons.Default.Menu, contentDescription = "Menú")
                    }
                },
                actions = {
                    Box(modifier = Modifier.padding(end = 8.dp)) {
                        IconButton(onClick = { /* Ver notificaciones */ }) {
                            Icon(Icons.Default.Notifications, contentDescription = "Notificaciones")
                        }
                        if (notificationCount > 0) {
                            Badge(
                                modifier = Modifier.align(Alignment.TopEnd).padding(top = 8.dp, end = 8.dp),
                                containerColor = Color.Red
                            ) {
                                Text(if (notificationCount > 9) "+9" else notificationCount.toString(), color = Color.White)
                            }
                        }
                    }
                }
            )
        },
        bottomBar = {
            Column(
                modifier = Modifier.fillMaxWidth().padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "© 2026 Taco'Os POC - Enterprise Edition",
                    style = MaterialTheme.typography.labelSmall,
                    color = Color.Gray
                )
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .background(MaterialTheme.colorScheme.background)
        ) {
            // Header con Imagen o Color Bonito
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp)
                    .background(
                        Brush.verticalGradient(
                            colors = listOf(PrimaryNavy, ActionBlue)
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "RESUMEN EJECUTIVO",
                        color = Color.White.copy(alpha = 0.7f),
                        style = MaterialTheme.typography.labelLarge,
                        letterSpacing = 2.sp
                    )
                    Text(
                        text = "$12,450.00",
                        color = Color.White,
                        style = MaterialTheme.typography.headlineLarge,
                        fontWeight = FontWeight.Black
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Botones Principales (Admin)
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                AdminButton(
                    title = "VENTAS",
                    icon = Icons.Default.ShoppingCart,
                    onClick = { /* Ir a vista POS */ }
                )
                Spacer(modifier = Modifier.height(16.dp))
                AdminButton(
                    title = "REPORTES",
                    icon = Icons.Default.Info,
                    onClick = { /* Ir a reportes */ }
                )
                Spacer(modifier = Modifier.height(16.dp))
                AdminButton(
                    title = "CAJEROS",
                    icon = Icons.Default.Person,
                    onClick = { /* Ir a cajeros */ }
                )
            }
        }
    }

    if (showMenu) {
        ModalNavigationDrawer(
            drawerContent = {
                ModalDrawerSheet {
                    Spacer(Modifier.height(12.dp))
                    NavigationDrawerItem(label = { Text("Mi Perfil") }, selected = false, onClick = { showMenu = false }, icon = { Icon(Icons.Default.Person, null) })
                    NavigationDrawerItem(label = { Text("Modo Oscuro") }, selected = false, onClick = { showMenu = false }, icon = { Icon(Icons.Default.Star, null) })
                    NavigationDrawerItem(label = { Text("Ajustes") }, selected = false, onClick = { showMenu = false }, icon = { Icon(Icons.Default.Settings, null) })
                    NavigationDrawerItem(label = { Text("Ayuda") }, selected = false, onClick = { showMenu = false }, icon = { Icon(Icons.Default.Info, null) })
                }
            },
            content = {}
        )
    }
}

@Composable
fun AdminButton(title: String, icon: ImageVector, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth(0.7f)
            .height(70.dp),
        shape = RoundedCornerShape(16.dp),
        colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy),
        elevation = ButtonDefaults.buttonElevation(defaultElevation = 4.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(icon, contentDescription = null, modifier = Modifier.size(24.dp))
            Spacer(modifier = Modifier.width(16.dp))
            Text(title, fontWeight = FontWeight.Black, fontSize = 18.sp, letterSpacing = 1.sp)
        }
    }
}
