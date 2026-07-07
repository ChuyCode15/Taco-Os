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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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

data class TacoNotification(
    val id: String,
    val title: String,
    val message: String,
    val date: String,
    val type: String, // "support", "sale", "alert"
    var isRead: Boolean = false
)

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
    
    // Estado Soporte (Burbuja)
    var showSupportBubble by remember { mutableStateOf(false) }
    var hasNewSupportMessage by remember { mutableStateOf(true) }

    // Notificaciones State
    val notifications = remember { mutableStateListOf(
        TacoNotification("1", "Soporte", "Tu ticket #123 ha sido respondido", "Hace 5 min", "support"),
        TacoNotification("2", "Venta Cancelada", "Se canceló una venta de $500", "Hoy 10:30 AM", "sale"),
        TacoNotification("3", "Licencia", "Tu licencia vence en 3 días", "Ayer", "alert")
    ) }
    
    var showNotificationMenu by remember { mutableStateOf(false) }
    var bellShaking by remember { mutableStateOf(false) }

    // Simular llegada de notificación
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
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        "MI PERFIL", 
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Black
                    )
                    AppleToggle(checked = isDarkMode, onCheckedChange = onThemeChange)
                }
                
                Text(
                    text = if(isDarkMode) "Modo Oscuro Activo" else "Modo Claro Activo",
                    modifier = Modifier.padding(horizontal = 24.dp, vertical = 4.dp),
                    style = MaterialTheme.typography.labelSmall,
                    color = Color.Gray
                )
                
                Spacer(Modifier.height(16.dp))
                Divider(modifier = Modifier.padding(horizontal = 24.dp))
                
                NavigationDrawerItem(
                    label = { Text("Ajustes", fontWeight = FontWeight.Bold) }, 
                    selected = false, 
                    onClick = { 
                        scope.launch { drawerState.close() }
                        navController.navigate("settings") 
                    }, 
                    icon = { Icon(Icons.Default.Settings, null) },
                    modifier = Modifier.padding(horizontal = 12.dp)
                )
                NavigationDrawerItem(
                    label = { Text("Ayuda / Soporte", fontWeight = FontWeight.Bold) }, 
                    selected = false, 
                    onClick = { 
                        scope.launch { drawerState.close() }
                        showSupportBubble = true 
                    }, 
                    icon = { Icon(Icons.Default.Info, null) },
                    modifier = Modifier.padding(horizontal = 12.dp)
                )
                
                Spacer(modifier = Modifier.weight(1f))
                
                Text(
                    "Cerrar Sesión", 
                    modifier = Modifier
                        .padding(24.dp)
                        .clickable { 
                            navController.navigate("login") {
                                popUpTo(0) { inclusive = true }
                            }
                        },
                    color = Color.Red,
                    fontWeight = FontWeight.Black
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
                        IconButton(onClick = { scope.launch { drawerState.open() } }) {
                            Icon(Icons.Default.Menu, contentDescription = "Menú")
                        }
                    },
                    actions = {
                        Box {
                            val shakeOffset by animateDpAsState(if (bellShaking) 5.dp else 0.dp)
                            IconButton(
                                onClick = { showNotificationMenu = !showNotificationMenu },
                                modifier = Modifier.offset(x = shakeOffset)
                            ) {
                                Icon(
                                    Icons.Default.Notifications, 
                                    contentDescription = "Notificaciones", 
                                    modifier = Modifier.size(28.dp),
                                    tint = if(notifications.any { !it.isRead }) ActionBlue else MaterialTheme.colorScheme.onSurface
                                )
                            }
                            if (notifications.any { !it.isRead }) {
                                Badge(
                                    modifier = Modifier.align(Alignment.TopEnd).padding(top = 8.dp, end = 8.dp),
                                    containerColor = Color.Red
                                ) {}
                            }
                            
                            DropdownMenu(
                                expanded = showNotificationMenu,
                                onDismissRequest = { showNotificationMenu = false },
                                modifier = Modifier
                                    .width(300.dp)
                                    .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(20.dp))
                            ) {
                                Text(
                                    "Notificaciones", 
                                    modifier = Modifier.padding(16.dp), 
                                    fontWeight = FontWeight.Black,
                                    fontSize = 20.sp
                                )
                                LazyColumn(modifier = Modifier.heightIn(max = 400.dp)) {
                                    items(notifications, key = { it.id }) { notif ->
                                        NotificationItem(
                                            notif = notif,
                                            onClick = { 
                                                notif.isRead = true
                                                showNotificationMenu = false
                                            },
                                            onDismiss = {
                                                notifications.remove(notif)
                                            }
                                        )
                                    }
                                }
                                if (notifications.isNotEmpty()) {
                                    TextButton(
                                        onClick = { notifications.clear(); showNotificationMenu = false },
                                        modifier = Modifier.fillMaxWidth()
                                    ) {
                                        Text("BORRAR TODO", color = Color.Red, fontWeight = FontWeight.Bold)
                                    }
                                } else {
                                    Text("Sin notificaciones", modifier = Modifier.fillMaxWidth().padding(16.dp), textAlign = TextAlign.Center, color = Color.Gray)
                                }
                            }
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
                )
            }
        ) { padding ->
            Box(modifier = Modifier.fillMaxSize()) {
                if (isDarkMode) {
                    Canvas(modifier = Modifier.fillMaxSize()) {
                        drawCircle(
                            color = Color.White.copy(alpha = 0.03f),
                            radius = 400f,
                            center = androidx.compose.ui.geometry.Offset(size.width * 0.8f, size.height * 0.2f)
                        )
                        drawCircle(
                            color = Color.White.copy(alpha = 0.02f),
                            radius = 600f,
                            center = androidx.compose.ui.geometry.Offset(size.width * 0.2f, size.height * 0.8f)
                        )
                    }
                }

                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
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
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("VENTAS HOY", color = Color.White.copy(alpha = 0.7f), fontWeight = FontWeight.Bold)
                            Text("$12,450.00", color = Color.White, fontSize = 36.sp, fontWeight = FontWeight.Black)
                        }
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    AdminButton(title = "VENTAS", icon = Icons.Default.ShoppingCart, onClick = { navController.navigate("sales") })
                    Spacer(modifier = Modifier.height(16.dp))
                    AdminButton(title = "REPORTES", icon = Icons.Default.List, onClick = { navController.navigate("reports") })
                    Spacer(modifier = Modifier.height(16.dp))
                    AdminButton(title = "CAJEROS", icon = Icons.Default.Person, onClick = { navController.navigate("cashiers") })
                }

                if (showSupportBubble) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.BottomEnd)
                            .padding(24.dp)
                            .size(60.dp)
                            .clip(CircleShape)
                            .background(ActionBlue)
                            .clickable { hasNewSupportMessage = false },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Outlined.MailOutline, contentDescription = null, tint = Color.White)
                        if (hasNewSupportMessage) {
                            Box(
                                modifier = Modifier
                                    .align(Alignment.TopEnd)
                                    .size(12.dp)
                                    .clip(CircleShape)
                                    .background(Color.Red)
                            )
                        }
                        IconButton(
                            onClick = { showSupportBubble = false },
                            modifier = Modifier.align(Alignment.TopStart).offset(x = (-8).dp, y = (-8).dp).size(24.dp)
                        ) {
                            Icon(Icons.Default.Close, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun AppleToggle(checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    val thumbOffset by animateDpAsState(if (checked) 22.dp else 2.dp)
    val bgColor by animateColorAsState(if (checked) ActionBlue else Color.LightGray)

    Box(
        modifier = Modifier
            .width(50.dp)
            .height(30.dp)
            .clip(CircleShape)
            .background(bgColor)
            .clickable { onCheckedChange(!checked) }
            .padding(4.dp),
        contentAlignment = Alignment.CenterStart
    ) {
        Box(
            modifier = Modifier
                .offset(x = thumbOffset)
                .size(22.dp)
                .clip(CircleShape)
                .background(Color.White)
        )
    }
}

@Composable
fun NotificationItem(notif: TacoNotification, onClick: () -> Unit, onDismiss: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(if(notif.isRead) Color.Transparent else ActionBlue))
        Spacer(modifier = Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(notif.title, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            Text(notif.message, fontSize = 12.sp, color = Color.Gray)
            Text(notif.date, fontSize = 10.sp, color = Color.LightGray)
        }
        IconButton(onClick = onDismiss) {
            Icon(Icons.Default.Delete, contentDescription = null, tint = Color.LightGray, modifier = Modifier.size(20.dp))
        }
    }
}

@Composable
fun AdminButton(title: String, icon: ImageVector, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth(0.85f)
            .height(70.dp),
        shape = RoundedCornerShape(22.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer,
            contentColor = MaterialTheme.colorScheme.onSecondaryContainer
        ),
        elevation = ButtonDefaults.buttonElevation(defaultElevation = 2.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(icon, contentDescription = null, modifier = Modifier.size(24.dp))
            Spacer(modifier = Modifier.width(16.dp))
            Text(title, fontWeight = FontWeight.Black, fontSize = 16.sp, letterSpacing = 1.sp)
            Spacer(modifier = Modifier.weight(1f))
            Icon(Icons.Default.ArrowForward, contentDescription = null)
        }
    }
}
