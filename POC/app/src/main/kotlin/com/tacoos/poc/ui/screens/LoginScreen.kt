package com.tacoos.poc.ui.screens

import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy

@Composable
fun LoginScreen(navController: NavController, viewModel: LoginViewModel = viewModel()) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsState()

    var showLoginBox by remember { mutableStateOf(false) }
    var showRegisterMode by remember { mutableStateOf(false) }

    val gso = remember {
        GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(GoogleSignInConfig.SERVER_CLIENT_ID)
            .requestEmail()
            .build()
    }
    val googleSignInClient = remember { GoogleSignIn.getClient(context as android.app.Activity, gso) }

    val googleSignInLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
        try {
            val account = task.getResult(ApiException::class.java)
            val idGoogle = account.id ?: return@rememberLauncherForActivityResult
            android.util.Log.d("TacoOs", "Google Sign-In success: id=$idGoogle, email=${account.email}")
            viewModel.onGoogleSignInResult(
                idGoogle = idGoogle,
                nombre = account.displayName ?: "",
                email = account.email ?: "",
                fotoUrl = account.photoUrl?.toString()
            )
        } catch (e: ApiException) {
            android.util.Log.e("TacoOs", "Google Sign-In error: status=${e.statusCode}, msg=${e.message}")
            Toast.makeText(context, "Error Google: ${e.localizedMessage ?: "desconocido"}", Toast.LENGTH_LONG).show()
        }
    }

    LaunchedEffect(uiState) {
        when (val state = uiState) {
            is LoginUiState.Success -> {
                val route = if (state.user.rol == "dueño" || state.user.rol == "administrador") "dashboard" else "sales"
                navController.navigate(route) {
                    popUpTo("login") { inclusive = true }
                }
                viewModel.resetState()
            }
            is LoginUiState.UserNotFound -> {
                // Ajuste: Mostrar error específico y llevar a registro
                Toast.makeText(context, "No estás registrado. Por favor, crea una cuenta.", Toast.LENGTH_LONG).show()
                navController.navigate("role_selection") {
                    popUpTo("login") { inclusive = true }
                }
                viewModel.resetState()
            }
            is LoginUiState.Error -> {
                Toast.makeText(context, state.message, Toast.LENGTH_SHORT).show()
                viewModel.resetState()
            }
            else -> {}
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        // Imagen de Fondo
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(PrimaryNavy, ActionBlue.copy(alpha = 0.8f))
                    )
                )
        ) {
            Text(
                text = "TACO'OS",
                modifier = Modifier
                    .align(Alignment.Center)
                    .padding(bottom = 100.dp),
                color = Color.White.copy(alpha = 0.15f),
                fontSize = 100.sp,
                fontWeight = FontWeight.Black,
                textAlign = TextAlign.Center,
                letterSpacing = (-5).sp
            )
        }

        // Botón Principal Login y Registro (Abajo Centrados)
        if (!showLoginBox) {
            Column(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 80.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "CONTROL FINANCIERO PROFESIONAL",
                    color = Color.White.copy(alpha = 0.8f),
                    style = MaterialTheme.typography.labelLarge,
                    letterSpacing = 2.sp,
                    modifier = Modifier.padding(bottom = 24.dp)
                )
                
                Button(
                    onClick = {
                        showRegisterMode = false
                        showLoginBox = true
                    },
                    modifier = Modifier
                        .fillMaxWidth(0.75f)
                        .height(65.dp),
                    shape = RoundedCornerShape(20.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = PrimaryNavy),
                    elevation = ButtonDefaults.buttonElevation(defaultElevation = 8.dp)
                ) {
                    Text("INICIAR SESIÓN", fontWeight = FontWeight.Black, fontSize = 16.sp, letterSpacing = 1.sp)
                }

                Spacer(modifier = Modifier.height(24.dp))

                Text(
                    text = "REGISTRARSE",
                    modifier = Modifier
                        .clickable {
                            showRegisterMode = true
                            showLoginBox = true
                        },
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    letterSpacing = 1.sp,
                    textAlign = TextAlign.Center
                )
            }
        }

        AnimatedVisibility(
            visible = showLoginBox,
            enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
            exit = slideOutVertically(targetOffsetY = { it }) + fadeOut(),
            modifier = Modifier.align(Alignment.BottomCenter)
        ) {
            LoginBox(
                isRegister = showRegisterMode,
                onClose = { showLoginBox = false },
                onGoogleLogin = {
                    googleSignInLauncher.launch(googleSignInClient.signInIntent)
                }
            )
        }

        if (uiState is LoginUiState.Loading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.3f))
                    .clickable(enabled = false) {},
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = Color.White)
            }
        }
    }
}

@Composable
fun LoginBox(isRegister: Boolean, onClose: () -> Unit, onGoogleLogin: () -> Unit) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight(0.6f)
            .clip(RoundedCornerShape(topStart = 40.dp, topEnd = 40.dp)),
        color = Color.White.copy(alpha = 0.95f),
        tonalElevation = 12.dp
    ) {
        Column(
            modifier = Modifier
                .padding(horizontal = 32.dp, vertical = 24.dp)
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .width(50.dp)
                    .height(5.dp)
                    .clip(RoundedCornerShape(2.5.dp))
                    .background(Color.Black.copy(alpha = 0.1f))
                    .clickable { onClose() }
            )

            Spacer(modifier = Modifier.height(40.dp))

            Text(
                text = if (isRegister) "Regístrate para disfrutar Taco'Os" else "Bienvenidos",
                color = PrimaryNavy,
                fontSize = 28.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = (-1).sp,
                textAlign = TextAlign.Center
            )

            Text(
                text = "Inicia sesión con Google account",
                color = PrimaryNavy.copy(alpha = 0.7f),
                style = MaterialTheme.typography.bodyLarge
            )

            Spacer(modifier = Modifier.height(50.dp))

            Button(
                onClick = onGoogleLogin,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(65.dp),
                shape = RoundedCornerShape(20.dp),
                colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy, contentColor = Color.White),
                elevation = ButtonDefaults.buttonElevation(defaultElevation = 4.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "G ", 
                        fontWeight = FontWeight.Bold, 
                        color = Color.White,
                        fontSize = 20.sp
                    )
                    Text(
                        text = if (isRegister) "REGÍSTRATE CON GOOGLE" else "INICIAR SESIÓN",
                        fontWeight = FontWeight.Black,
                        fontSize = 16.sp,
                        letterSpacing = 1.sp
                    )
                }
            }
        }
    }
}
