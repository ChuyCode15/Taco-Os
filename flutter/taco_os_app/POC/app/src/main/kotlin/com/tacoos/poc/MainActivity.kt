package com.tacoos.poc

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.tacoos.poc.ui.screens.*
import com.tacoos.poc.ui.theme.TacoOsTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            TacoOsTheme {
                val navController = rememberNavController()
                
                NavHost(navController = navController, startDestination = "login") {
                    composable("login") { LoginScreen(navController) }
                    composable("role_selection") { RoleSelectionScreen(navController) }
                    composable("business_registration") { BusinessRegistrationScreen(navController) }
                    composable("cashier_assignment") { CashierAssignmentScreen(navController) }
                    composable("dashboard") { DashboardScreen(navController) }
                }
            }
        }
    }
}
