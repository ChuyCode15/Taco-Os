package com.tacoos.poc.presentation.ui.auth


import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.tacoos.poc.presentation.layout.AutoImageSlider
import com.tacoos.poc.presentation.uiState.auth.AuthUiState
import com.tacoos.poc.presentation.uiState.auth.GoogleAuthUiClient
import com.tacoos.poc.presentation.viewmodel.auth.AuthViewModel
import kotlinx.coroutines.launch

/**
 * Pantalla de inicio que gestiona la autenticación del usuario mediante Google.
 *
 * @param onAuthenticated Callback que se ejecuta cuando el usuario ha sido autenticado con éxito.
 * @param viewModel ViewModel que maneja la lógica de autenticación y el estado de la UI.
 */
@Composable
fun HomeScreen(
    onAuthenticated: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsState()
    val scope = rememberCoroutineScope()
    val googleAuthUiClient = remember { GoogleAuthUiClient(context) }

    LaunchedEffect(uiState.isAuthenticated) {
        if (uiState.isAuthenticated) onAuthenticated()
    }

    HomeScreenContent(
        uiState = uiState,
        onRegisterClick = {
            scope.launch {
                val result = googleAuthUiClient.requestIdToken(filterByAuthorizedAccounts = false)
                result.onSuccess { userData -> viewModel.onGoogleSignIn(userData) }
                    .onFailure { error -> 
                        val message = error.message ?: "Error desconocido en Google Auth"
                        viewModel.onGoogleFlowFailed(message)
                    }
            }
        },
        onSignInClick = {
            scope.launch {
                val result = googleAuthUiClient.requestIdToken(filterByAuthorizedAccounts = true)
                result.onSuccess { userData -> viewModel.onGoogleSignIn(userData) }
                    .onFailure { error -> 
                        val message = error.message ?: "Error desconocido en Google Auth"
                        viewModel.onGoogleFlowFailed(message)
                    }
            }
        }
    )
}




/**
 * Contenido visual de la pantalla de inicio.
 *
 * @param uiState Estado actual de la autenticación.
 * @param onRegisterClick Acción al pulsar el botón de registro con Google.
 * @param onSignInClick Acción al pulsar el botón de inicio de sesión.
 * @param modifier Modificador para personalizar el diseño del contenedor.
 */
@Composable
fun HomeScreenContent(
    uiState: AuthUiState,
    onRegisterClick: () -> Unit,
    onSignInClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ){
        AutoImageSlider() // funcion de imagenes auto scroll

        Text(
            text = "TACOOS",
            fontSize = 34.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFFE3F2FD),
            letterSpacing = 1.5.sp,
            modifier = Modifier
                .align(Alignment.TopCenter)
                .padding(top = 32.dp)
        )

        Column(
            modifier = Modifier
                .fillMaxSize(),
            verticalArrangement = Arrangement.Bottom,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(0.4f)
                    .clip(RoundedCornerShape(topStart = 30.dp, topEnd = 30.dp))
                    .background(Color.White)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Bienvenido",
                        fontSize = 20.sp,
                        style = MaterialTheme.typography.headlineSmall,
                        color = Color(0xFF0D47A1)
                    )

                    Spacer(modifier = Modifier.height(24.dp))

                    Button(
                        onClick = onSignInClick,
                        enabled = !uiState.isLoading,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF0D47A1))
                    ) {
                        Text(
                            text = "Iniciar sesión",
                            color = Color.White,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    OutlinedButton(
                        onClick = onRegisterClick,
                        enabled = !uiState.isLoading,
                        modifier = Modifier.fillMaxWidth(),
                        border = BorderStroke(1.dp, Color.Black),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.Blue)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = "G",
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.Yellow,
                                modifier = Modifier.padding(end = 12.dp)
                            )
                            Text(
                                text = "Registrarse con Google",
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(24.dp))

                    if (uiState.isLoading) {
                        CircularProgressIndicator()
                    }

                    uiState.errorMessage?.let { message ->
                        Text(
                            text = message,
                            color = MaterialTheme.colorScheme.error
                        )
                    }
                }
            }
        }
    }
}



/**
 * Previsualización de la pantalla de inicio.
 */
@Preview(showBackground = true, showSystemUi = true)
@Composable
fun HomeScreenPreview() {
    HomeScreenContent(
        uiState = AuthUiState(),
        onRegisterClick = {},
        onSignInClick = {}
    )
}