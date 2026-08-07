package com.tacoos.poc.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import coil.compose.AsyncImage
import com.tacoos.poc.ui.components.AiInsightCard
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
    
    // Estado para el microservicio de IA (Data Science)
    var aiMessage by remember { mutableStateOf("Tus ventas han subido un 15% hoy comparado con el martes pasado. ¡Buen trabajo!") }
    var showAiInsight by remember { mutableStateOf(true) }

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
                        .padding(horizontal = 20.dp, vertical = 10.dp)
                        .clip(RoundedCornerShape(32.dp))
                        .background(
                            Brush.linearGradient(
                                colors = if(isDarkMode) listOf(Color(0xFF2C2C2E), Color(0xFF1C1C1E)) else listOf(PrimaryNavy, ActionBlue)
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    val imageUrls = remember {
                        listOf(
                            "https://picsum.photos/id/10/800/400",
                            "https://picsum.photos/id/11/800/400",
                            "https://picsum.photos/id/12/800/400",
                            "https://picsum.photos/id/13/800/400",
                            "https://picsum.photos/id/14/800/400"
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
                        val index = page % imageUrls.size
                        AsyncImage(
                            model = imageUrls[index],
                            contentDescription = null,
                            modifier = Modifier.fillMaxSize(),
                            contentScale = ContentScale.Crop
                        )
                    }
                }

                // Componente de IA (Insights de Data Science)
                AiInsightCard(
                    message = aiMessage,
                    visible = showAiInsight,
                    onClose = { showAiInsight = false }
                )

                Spacer(modifier = Modifier.height(8.dp))

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
