package com.tacoos.poc.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(navController: NavController) {
    val notificationCount = 12
    
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(
                modifier = Modifier.width(300.dp),
                drawerContainerColor = MaterialTheme.colorScheme.surface,
                drawerShape = RoundedCornerShape(topEnd = 24.dp, bottomEnd = 24.dp)
            ) {
                Spacer(Modifier.height(48.dp))
                Text(
                    "MI PERFIL", 
                    modifier = Modifier.padding(24.dp), 
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Black
                )
                Divider(modifier = Modifier.padding(horizontal = 24.dp))
                NavigationDrawerItem(label = { Text("Modo Oscuro") }, selected = false, onClick = { }, icon = { Icon(Icons.Default.Star, null) })
                NavigationDrawerItem(label = { Text("Ajustes") }, selected = false, onClick = { }, icon = { Icon(Icons.Default.Settings, null) })
                NavigationDrawerItem(label = { Text("Ayuda") }, selected = false, onClick = { }, icon = { Icon(Icons.Default.Info, null) })
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    "Cerrar Sesión", 
                    modifier = Modifier.padding(24.dp).clickable { /* Logout */ },
                    color = Color.Red,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { 
                        Text("ADMINISTRADOR", fontWeight = FontWeight.Black, letterSpacing = 1.sp, fontSize = 18.sp)
                    },
                    navigationIcon = {
                        IconButton(onClick = { 
                            scope.launch { drawerState.open() } 
                        }) {
                            Icon(Icons.Default.MoreVert, contentDescription = "Opciones")
                        }
                    },
                    actions = {
                        Box(modifier = Modifier.padding(end = 16.dp)) {
                            IconButton(onClick = { /* Ver notificaciones */ }) {
                                Icon(Icons.Default.Notifications, contentDescription = "Notificaciones", modifier = Modifier.size(28.dp))
                            }
                            if (notificationCount > 0) {
                                Badge(
                                    modifier = Modifier.align(Alignment.TopEnd).padding(top = 4.dp, end = 4.dp),
                                    containerColor = Color.Red,
                                    contentColor = Color.White
                                ) {
                                    Text(if (notificationCount > 9) "+9" else notificationCount.toString(), fontSize = 10.sp)
                                }
                            }
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
                )
            },
            bottomBar = {
                Box(
                    modifier = Modifier.fillMaxWidth().padding(bottom = 24.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "© 2026 DESARROLLO TACO'OS POC",
                        style = MaterialTheme.typography.labelSmall,
                        color = Color.Gray.copy(alpha = 0.6f),
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                }
            }
        ) { padding ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Imagen superior / Espacio de diseño
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp)
                        .padding(24.dp)
                        .clip(RoundedCornerShape(32.dp))
                        .background(
                            Brush.linearGradient(
                                colors = listOf(PrimaryNavy, ActionBlue)
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("RESUMEN HOY", color = Color.White.copy(alpha = 0.7f), fontWeight = FontWeight.Bold)
                        Text("$12,450.00", color = Color.White, fontSize = 40.sp, fontWeight = FontWeight.Black)
                    }
                }

                Spacer(modifier = Modifier.height(32.dp))

                // Los 3 Botones principales
                AdminButton(
                    title = "VENTAS",
                    icon = Icons.Default.ShoppingCart,
                    onClick = { navController.navigate("sales") }
                )
                Spacer(modifier = Modifier.height(20.dp))
                AdminButton(
                    title = "REPORTES",
                    icon = Icons.Default.Info,
                    onClick = { /* Reportes */ }
                )
                Spacer(modifier = Modifier.height(20.dp))
                AdminButton(
                    title = "CAJEROS",
                    icon = Icons.Default.Person,
                    onClick = { /* Cajeros */ }
                )
            }
        }
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
