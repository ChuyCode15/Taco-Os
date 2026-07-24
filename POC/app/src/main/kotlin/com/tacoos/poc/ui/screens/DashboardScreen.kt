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
import com.tacoos.poc.ui.components.AppDrawerContent
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

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
    
    var showSupportBubble by remember { mutableStateOf(false) }
    var hasNewSupportMessage by remember { mutableStateOf(true) }


    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            AppDrawerContent(
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
                        Text("ADMINISTRADOR", fontWeight = FontWeight.Black, letterSpacing = 1.sp, fontSize = 18.sp)
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
        }
    }
}

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
