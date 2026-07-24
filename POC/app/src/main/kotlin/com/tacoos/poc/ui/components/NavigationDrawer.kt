package com.tacoos.poc.ui.components

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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import coil.compose.AsyncImage
import com.tacoos.poc.ui.screens.GoogleSignInState
import com.tacoos.poc.ui.theme.PrimaryNavy

@Composable
fun AppDrawerContent(
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit,
    navController: NavController,
    onClose: () -> Unit
) {
    ModalDrawerSheet(modifier = Modifier.width(300.dp)) {
        Column(modifier = Modifier.fillMaxSize()) {
            // HEADER: Foto ovalada y nombre del usuario obtenido de Google
            Box(modifier = Modifier.fillMaxWidth().background(PrimaryNavy).padding(top = 48.dp, start = 24.dp, end = 24.dp, bottom = 24.dp)) {
                Column {
                    Surface(
                        modifier = Modifier.size(width = 80.dp, height = 65.dp).clip(RoundedCornerShape(30.dp)), // Forma ovalada
                        color = Color.White.copy(alpha = 0.2f)
                    ) {
                        if (GoogleSignInState.fotoUrl != null) {
                            AsyncImage(
                                model = GoogleSignInState.fotoUrl,
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
                    
                    // Mostramos el nombre directamente desde el estado de Google
                    Text(
                        text = GoogleSignInState.nombre.ifEmpty { "Usuario Taco-Os" }, 
                        color = Color.White, 
                        fontWeight = FontWeight.Black, 
                        fontSize = 18.sp
                    )
                    
                    Text(
                        text = GoogleSignInState.rol.replaceFirstChar { it.uppercase() }, 
                        color = Color.White.copy(alpha = 0.7f), 
                        fontSize = 14.sp
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            // OPCIONES
            DrawerItem(Icons.Default.Dashboard, "Dashboard") { onClose(); navController.navigate("dashboard") }
            DrawerItem(Icons.Default.PointOfSale, "Ventas") { onClose(); navController.navigate("sales") }
            DrawerItem(Icons.Default.BarChart, "Reportes") { onClose(); navController.navigate("reports") }
            DrawerItem(Icons.Default.Groups, "Mi Equipo") { onClose(); navController.navigate("cashiers") }
            DrawerItem(Icons.Default.Settings, "Ajustes") { onClose(); navController.navigate("settings") }

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
