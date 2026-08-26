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

/**
 * Define las rutas constantes utilizadas para la navegación en la aplicación.
 */
object Routes {
    /** Ruta de la pantalla de bienvenida/splash. */
    const val SPLASH = "splash"
    /** Ruta de la pantalla principal de inicio/login. */
    const val HOME = "home"
    /** Ruta de la pantalla de selección de rol. */
    const val ROLE_SELECTION = "role_selection"
    /** Ruta de la pantalla de registro de negocio. */
    const val BUSINESS_REGISTRATION = "business_registration"
    /** Ruta del tablero principal (Dashboard). */
    const val DASHBOARD = "dashboard"
    /** Ruta de la lista de cajeros/equipo. */
    const val CASHIERS = "cashiers"
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
    }
}
