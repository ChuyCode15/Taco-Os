package com.tacoos.poc.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.tacoos.poc.presentation.ui.auth.HomeScreen
import com.tacoos.poc.presentation.ui.auth.RoleSelectionScreen
import com.tacoos.poc.presentation.ui.splash.SplashScreen
import com.tacoos.poc.presentation.ui.negocio.BusinessRegistrationScreen
import com.tacoos.poc.presentation.ui.Administrador.DashboardScreen
import com.tacoos.poc.presentation.ui.Administrador.CashierListScreen
import com.tacoos.poc.presentation.ui.ops.*
import com.tacoos.poc.presentation.ui.producto.ProductsScreen
import com.tacoos.poc.presentation.ui.reportes.ReportsScreen
import com.tacoos.poc.presentation.ui.ventas.SalesScreen
import com.tacoos.poc.presentation.ui.configuracion.SettingsScreen
import com.tacoos.poc.presentation.ui.cajero.TeamScreen
import androidx.navigation.NavType
import androidx.navigation.navArgument

/**
 * Define las rutas constantes utilizadas para la navegación en la aplicación.
 */
object Routes {
    const val SPLASH = "splash"
    const val HOME = "home"
    const val ROLE_SELECTION = "role_selection"
    const val BUSINESS_REGISTRATION = "business_registration"
    const val DASHBOARD = "dashboard"
    const val CASHIERS = "cashiers"
    
    const val SALES = "sales"
    const val REPORTS = "reports"
    const val PRODUCTS = "products"
    const val SETTINGS = "settings"
    const val TEAM = "team"
    
    const val DAILY_CUT = "daily_cut/{shiftId}"
    const val EXPENSES = "expenses/{shiftId}"
    const val LICENSE = "license"
    const val NOTIFICATIONS = "notifications"
}

/**
 * Configura el grafo de navegación de la aplicación.
 * 
 * @param navController Controlador de navegación. Por defecto crea uno recordable.
 * @param isDarkMode Estado actual del tema oscuro.
 * @param onThemeChange Función para alternar entre temas.
 */
@Composable
fun AppNavGraph(
    navController: NavHostController = rememberNavController(),
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit
) {
    NavHost(navController = navController, startDestination = Routes.SPLASH) {

        composable(Routes.SPLASH) {
            SplashScreen(
                onSplashFinished = { isAuthenticated ->
                    if (isAuthenticated) {
                        navController.navigate(Routes.ROLE_SELECTION) {
                            popUpTo(Routes.SPLASH) { inclusive = true }
                        }
                    } else {
                        navController.navigate(Routes.HOME) {
                            popUpTo(Routes.SPLASH) { inclusive = true }
                        }
                    }
                }
            )
        }

        composable(Routes.HOME) {
            HomeScreen(
                onAuthenticated = {
                    navController.navigate(Routes.ROLE_SELECTION) {
                        popUpTo(Routes.HOME) { inclusive = true }
                    }
                }
            )
        }

        composable(Routes.ROLE_SELECTION) {
            RoleSelectionScreen(
                onAdminSelected = {
                    navController.navigate(Routes.BUSINESS_REGISTRATION)
                },
                onCajeroSelected = {
                    navController.navigate(Routes.DASHBOARD)
                }
            )
        }

        composable(Routes.BUSINESS_REGISTRATION) {
            BusinessRegistrationScreen(
                onSuccess = {
                    navController.navigate(Routes.DASHBOARD) {
                        popUpTo(Routes.BUSINESS_REGISTRATION) { inclusive = true }
                    }
                }
            )
        }

        composable(Routes.DASHBOARD) {
            DashboardScreen(
                navController = navController,
                isDarkMode = isDarkMode,
                onThemeChange = onThemeChange
            )
        }

        composable(Routes.CASHIERS) {
            CashierListScreen(onBack = { navController.popBackStack() })
        }

        composable(Routes.SALES) {
            SalesScreen(navController = navController, isDarkMode = isDarkMode, onThemeChange = onThemeChange)
        }

        composable(Routes.REPORTS) {
            ReportsScreen(navController = navController, isDarkMode = isDarkMode, onThemeChange = onThemeChange)
        }

        composable(Routes.PRODUCTS) {
            ProductsScreen(navController = navController, isDarkMode = isDarkMode, onThemeChange = onThemeChange)
        }

        composable(Routes.SETTINGS) {
            SettingsScreen(navController = navController, isDarkMode = isDarkMode, onThemeChange = onThemeChange)
        }

        composable(Routes.TEAM) {
            TeamScreen(navController = navController, isDarkMode = isDarkMode, onThemeChange = onThemeChange)
        }

        composable(
            route = Routes.DAILY_CUT,
            arguments = listOf(navArgument("shiftId") { type = NavType.LongType })
        ) { backStackEntry ->
            val shiftId = backStackEntry.arguments?.getLong("shiftId") ?: 0L
            DailyCutScreen(navController = navController, shiftId = shiftId)
        }

        composable(
            route = Routes.EXPENSES,
            arguments = listOf(navArgument("shiftId") { type = NavType.LongType })
        ) { backStackEntry ->
            val shiftId = backStackEntry.arguments?.getLong("shiftId") ?: 0L
            ExpenseScreen(navController = navController, shiftId = shiftId)
        }

        composable(Routes.LICENSE) {
            LicenseScreen(navController = navController)
        }

        composable(Routes.NOTIFICATIONS) {
            NotificationScreen(navController = navController)
        }
    }
}
