package com.tacoos.poc.ui.screens

import android.media.RingtoneManager
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.MailOutline
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * TacoNotification: Modelo de datos para las alertas del sistema.
 */
data class TacoNotification(
    val id: String,
    val title: String,
    val message: String,
    val date: String,
    val type: String, // "support", "sale", "alert"
    var isRead: Boolean = false
)

/**
 * DashboardScreen: Panel principal de control para el Administrador.
 * Inyección de dependencias: NavController para navegación entre módulos (Ventas, Reportes, Cajeros).
 * Manejo de UI: Integra Modo Oscuro dinámico y banner interactivo.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    navController: NavController, 
    isDarkMode: Boolean, 
    onThemeChange: (Boolean) -> Unit
) {
    val scope = rememberCoroutineScope()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val context = LocalContext.current
    
    // Estado Soporte: Controla la visibilidad de la burbuja flotante de chat.
    var showSupportBubble by remember { mutableStateOf(false) }
    var hasNewSupportMessage by remember { mutableStateOf(true) }

    // Estado Notificaciones: Lista reactiva para el menú de la campana.
    val notifications = remember { mutableStateListOf<TacoNotification>(
        TacoNotification("1", "Soporte", "Tu ticket #123 ha sido respondido", "Hace 5 min", "support"),
        TacoNotification("2", "Venta Cancelada", "Se canceló una venta de $500", "Hoy 10:30 AM", "sale")
    ) }
    
    var showNotificationMenu by remember { mutableStateOf(false) }
    var bellShaking by remember { mutableStateOf(false) }

    // Simulación de llegada de notificación: Activa animación de campana y sonido.
    LaunchedEffect(Unit) {
        delay(5000)
        bellShaking = true
        try {
            val notificationUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val r = RingtoneManager.getRingtone(context, notificationUri)
            r.play()
        } catch (e: Exception) {}
        delay(1000)
        bellShaking = false
    }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(
                modifier = Modifier.width(300.dp),
                drawerContainerColor = MaterialTheme.colorScheme.surface,
                drawerShape = RoundedCornerShape(topEnd = 24.dp, bottomEnd = 24.dp)
            ) {
                Spacer(Modifier.height(48.dp))
                Row(modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("MI PERFIL", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Black)
                    // Componente Toggle estilo Apple para Modo Oscuro.
                    AppleToggle(checked = isDarkMode, onCheckedChange = onThemeChange)
                }
                Spacer(Modifier.height(16.dp))
                // Elementos de navegación lateral.
                NavigationDrawerItem(label = { Text("Ajustes") }, selected = false, onClick = { scope.launch { drawerState.close() }; navController.navigate("settings") }, icon = { Icon(Icons.Default.Settings, null) })
                NavigationDrawerItem(label = { Text("Ayuda / Soporte") }, selected = false, onClick = { scope.launch { drawerState.close() }; showSupportBubble = true }, icon = { Icon(Icons.Default.Info, null) })
                Spacer(modifier = Modifier.weight(1f))
                // Cerrar Sesión: Limpia estado y regresa a Login.
                Text("Cerrar Sesión", modifier = Modifier.padding(24.dp).clickable { navController.navigate("login") { popUpTo(0) } }, color = Color.Red, fontWeight = FontWeight.Black)
            }
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("ADMINISTRADOR", fontWeight = FontWeight.Black) },
                    navigationIcon = {
                        IconButton(onClick = { scope.launch { drawerState.open() } }) { Icon(Icons.Default.Menu, null) }
                    },
                    actions = {
                        Box {
                            // Animación de campana (Shake) cuando llega notificación.
                            val shakeOffset by animateDpAsState(if (bellShaking) 5.dp else 0.dp)
                            IconButton(onClick = { showNotificationMenu = !showNotificationMenu }, modifier = Modifier.offset(x = shakeOffset)) {
                                Icon(Icons.Default.Notifications, null, tint = if(notifications.any { !it.isRead }) ActionBlue else MaterialTheme.colorScheme.onSurface)
                            }
                            
                            // Menú Desplegable de Notificaciones.
                            DropdownMenu(
                                expanded = showNotificationMenu,
                                onDismissRequest = { showNotificationMenu = false },
                                modifier = Modifier.width(280.dp).background(MaterialTheme.colorScheme.surface, RoundedCornerShape(16.dp))
                            ) {
                                Text("Notificaciones", modifier = Modifier.padding(16.dp), fontWeight = FontWeight.Black)
                                Column(modifier = Modifier.heightIn(max = 300.dp).verticalScroll(rememberScrollState())) {
                                    if (notifications.isEmpty()) {
                                        Text("No hay notificaciones", modifier = Modifier.fillMaxWidth().padding(16.dp), textAlign = TextAlign.Center, color = Color.Gray)
                                    } else {
                                        notifications.forEach { notif ->
                                            NotificationItem(notif = notif, onClick = { 
                                                notif.isRead = true
                                                showNotificationMenu = false
                                                if(notif.type == "support") showSupportBubble = true
                                                if(notif.type == "sale") navController.navigate("sales")
                                            }, onDismiss = { notifications.remove(notif) })
                                        }
                                    }
                                }
                                if (notifications.isNotEmpty()) {
                                    TextButton(onClick = { notifications.clear(); showNotificationMenu = false }, modifier = Modifier.fillMaxWidth()) {
                                        Text("BORRAR TODO", color = Color.Red)
                                    }
                                }
                            }
                        }
                    }
                )
            }
        ) { padding ->
            Box(modifier = Modifier.fillMaxSize().padding(padding)) {
                // Efecto visual de fondo para el Dashboard (Círculos difuminados).
                if (isDarkMode) {
                    Canvas(modifier = Modifier.fillMaxSize()) {
                        drawCircle(color = Color.White.copy(alpha = 0.03f), radius = 400f, center = androidx.compose.ui.geometry.Offset(size.width * 0.8f, size.height * 0.2f))
                    }
                }
                Column(modifier = Modifier.fillMaxSize(), horizontalAlignment = Alignment.CenterHorizontally) {
                    // Banner Dinámico: Rotación de imágenes y resumen de ventas.
                    val banners = listOf(
                        "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80",
                        "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=500&q=80",
                        "https://images.unsplash.com/photo-1513135065346-a098a63a73ee?w=500&q=80"
                    )
                    var currentBannerIndex by remember { mutableStateOf(0) }
                    LaunchedEffect(Unit) {
                        while(true) {
                            delay(5000)
                            currentBannerIndex = (currentBannerIndex + 1) % banners.size
                        }
                    }

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(160.dp)
                            .padding(16.dp)
                            .clip(RoundedCornerShape(24.dp))
                            .background(Color.LightGray)
                    ) {
                        Box(modifier = Modifier.fillMaxSize().background(Brush.linearGradient(colors = listOf(PrimaryNavy, ActionBlue))), contentAlignment = Alignment.Center) {
                            Text("BANNER: ${banners[currentBannerIndex].takeLast(10)}", color = Color.White.copy(alpha = 0.5f))
                        }
                        
                        Column(
                            modifier = Modifier.align(Alignment.Center),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text("VENTAS HOY", color = Color.White.copy(alpha = 0.7f), fontWeight = FontWeight.Bold)
                            Text("$12,450.00", color = Color.White, fontSize = 32.sp, fontWeight = FontWeight.Black)
                        }
                    }

                    Spacer(Modifier.height(16.dp))
                    // Botones principales de administración.
                    AdminButton(title = "VENTAS", icon = Icons.Default.ShoppingCart, onClick = { navController.navigate("sales") })
                    Spacer(Modifier.height(12.dp))
                    AdminButton(title = "REPORTES", icon = Icons.Default.List, onClick = { navController.navigate("reports") })
                    Spacer(Modifier.height(12.dp))
                    AdminButton(title = "CAJEROS", icon = Icons.Default.Person, onClick = { navController.navigate("cashiers") })
                }
                
                // Burbuja Flotante de Soporte: Aparece al solicitar ayuda.
                if (showSupportBubble) {
                    Box(modifier = Modifier.align(Alignment.BottomEnd).padding(24.dp).size(60.dp).clip(CircleShape).background(ActionBlue).clickable { hasNewSupportMessage = false }, contentAlignment = Alignment.Center) {
                        Icon(Icons.Outlined.MailOutline, null, tint = Color.White)
                        if (hasNewSupportMessage) Box(modifier = Modifier.align(Alignment.TopEnd).size(12.dp).clip(CircleShape).background(Color.Red))
                        // Botón de cierre para minimizar la burbuja.
                        IconButton(onClick = { showSupportBubble = false }, modifier = Modifier.align(Alignment.TopStart).offset(x = (-8).dp, y = (-8).dp).size(24.dp)) {
                            Icon(Icons.Default.Close, null, tint = Color.White, modifier = Modifier.size(12.dp))
                        }
                    }
                }
            }
        }
    }
}

/**
 * AppleToggle: Interruptor ovalado personalizado con estética iOS.
 */
@Composable
fun AppleToggle(checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    val thumbOffset by animateDpAsState(if (checked) 22.dp else 2.dp)
    val bgColor by animateColorAsState(if (checked) ActionBlue else Color.LightGray)

    Box(
        modifier = Modifier.width(50.dp).height(30.dp).clip(CircleShape).background(bgColor).clickable { onCheckedChange(!checked) }.padding(4.dp),
        contentAlignment = Alignment.CenterStart
    ) {
        Box(modifier = Modifier.offset(x = thumbOffset).size(22.dp).clip(CircleShape).background(Color.White))
    }
}

/**
 * NotificationItem: Representación visual de una alerta en el menú desplegable.
 */
@Composable
fun NotificationItem(notif: TacoNotification, onClick: () -> Unit, onDismiss: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().clickable { onClick() }.padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(if(notif.isRead) Color.Transparent else ActionBlue))
        Spacer(Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(notif.title, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            Text(notif.message, fontSize = 12.sp, color = Color.Gray)
        }
        IconButton(onClick = onDismiss) {
            Icon(Icons.Default.Delete, null, tint = Color.LightGray, modifier = Modifier.size(20.dp))
        }
    }
}

/**
 * AdminButton: Botón de acceso directo a módulos de administración.
 */
@Composable
fun AdminButton(title: String, icon: ImageVector, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(0.85f).height(70.dp),
        shape = RoundedCornerShape(22.dp),
        colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.secondaryContainer, contentColor = MaterialTheme.colorScheme.onSecondaryContainer)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
            Icon(icon, null, modifier = Modifier.size(24.dp))
            Spacer(modifier = Modifier.width(16.dp))
            Text(title, fontWeight = FontWeight.Black, fontSize = 16.sp)
            Spacer(modifier = Modifier.weight(1f))
            Icon(Icons.Default.ArrowForward, null)
        }
    }
}
