package com.tacoos.poc

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.tacoos.poc.ui.screens.*
import com.tacoos.poc.ui.theme.TacoOsTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            var isDarkMode by remember { mutableStateOf(false) }
            
            TacoOsTheme(darkTheme = isDarkMode) {
                val navController = rememberNavController()
                
                NavHost(navController = navController, startDestination = "login") {
                    composable("login") { LoginScreen(navController) }
                    composable("role_selection") { RoleSelectionScreen(navController) }
                    composable("business_registration") { BusinessRegistrationScreen(navController) }
                    composable("cashier_assignment") { CashierAssignmentScreen(navController) }
                    composable("dashboard") { 
                        DashboardScreen(navController, onThemeChange = { isDarkMode = it }, isDarkMode = isDarkMode) 
                    }
                    composable("sales") { 
                        SalesScreen(navController, isDarkMode = isDarkMode, onThemeChange = { isDarkMode = it }) 
                    }
                    composable("settings") { PlaceholderScreen(navController, "Ajustes") }
                    composable("reports") { ReportsScreen(navController) }
                    composable("cashiers") { TeamScreen(navController) }
                }
            }
        }
    }
}

@Composable
fun PlaceholderScreen(navController: NavController, title: String) {
    Scaffold(
        topBar = {
            @OptIn(ExperimentalMaterial3Api::class)
            TopAppBar(
                title = { Text(title, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Box(modifier = Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
            Text("Pantalla de $title en desarrollo", style = MaterialTheme.typography.headlineSmall)
        }
    }
}
