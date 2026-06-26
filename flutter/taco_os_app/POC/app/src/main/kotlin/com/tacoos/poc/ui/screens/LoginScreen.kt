package com.tacoos.poc.ui.screens

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.GlassBlue
import com.tacoos.poc.ui.theme.PrimaryNavy

@Composable
fun LoginScreen(navController: NavController) {
    var showLoginBox by remember { mutableStateOf(false) }
    var showRegisterMode by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize()) {
        // Fondo: Imagen alegórica (Simulada con Gradiente Profesional)
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(PrimaryNavy, ActionBlue)
                    )
                )
        ) {
            // Aquí iría la imagen de media pantalla superior
            // Image(painter = painterResource(id = R.drawable.taco_business), ...)
            Text(
                text = "TACO'OS\nOPERATIONS",
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = 100.dp),
                color = Color.White.copy(alpha = 0.2f),
                fontSize = 60.sp,
                fontWeight = FontWeight.Black,
                textAlign = TextAlign.Center,
                lineHeight = 50.sp
            )
        }

        // Esquina Superior Derecha: Registrarse
        Text(
            text = "Registrarse",
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(24.dp)
                .clickable { 
                    showRegisterMode = true
                    showLoginBox = true 
                },
            color = Color.White,
            fontWeight = FontWeight.Bold,
            style = MaterialTheme.typography.bodyLarge
        )

        // Botón Principal Centro-Abajo
        if (!showLoginBox) {
            Column(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 80.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Gestiona tu negocio como un profesional",
                    color = Color.White,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(horizontal = 40.dp, vertical = 24.dp)
                )
                Button(
                    onClick = { 
                        showRegisterMode = false
                        showLoginBox = true 
                    },
                    modifier = Modifier
                        .fillMaxWidth(0.8f)
                        .height(60.dp),
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = ActionBlue)
                ) {
                    Text("INICIAR SESIÓN", fontWeight = FontWeight.Black, letterSpacing = 1.sp)
                }
            }
        }

        // Cuadro de Login/Register (Glass Effect)
        AnimatedVisibility(
            visible = showLoginBox,
            enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
            exit = slideOutVertically(targetOffsetY = { it }) + fadeOut(),
            modifier = Modifier.align(Alignment.BottomCenter)
        ) {
            LoginBox(
                isRegister = showRegisterMode,
                onClose = { showLoginBox = false },
                onGoogleLogin = { navController.navigate("role_selection") }
            )
        }
    }
}

@Composable
fun LoginBox(isRegister: Boolean, onClose: () -> Unit, onGoogleLogin: () -> Unit) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight(0.7f)
            .clip(RoundedCornerShape(topStart = 32.dp, topEnd = 32.dp)),
        color = GlassBlue,
        tonalElevation = 8.dp
    ) {
        Column(
            modifier = Modifier
                .padding(32.dp)
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .width(40.dp)
                    .height(4.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(Color.White.copy(alpha = 0.3f))
                    .clickable { onClose() }
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Text(
                text = if (isRegister) "Bienvenido" else "Welcome",
                color = Color.White,
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
            
            Text(
                text = if (isRegister) "Crea tu cuenta profesional" else "Ingresa tus credenciales",
                color = Color.White.copy(alpha = 0.7f),
                style = MaterialTheme.typography.bodyMedium
            )

            Spacer(modifier = Modifier.height(32.dp))

            if (!isRegister) {
                OutlinedTextField(
                    value = email,
                    onValueChange = { email = it },
                    label = { Text("Usuario", color = Color.White.copy(alpha = 0.6f)) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        unfocusedBorderColor = Color.White.copy(alpha = 0.3f),
                        focusedBorderColor = Color.White,
                        cursorColor = Color.White,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    )
                )
                
                Spacer(modifier = Modifier.height(16.dp))
                
                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Contraseña", color = Color.White.copy(alpha = 0.6f)) },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    visualTransformation = PasswordVisualTransformation(),
                    colors = OutlinedTextFieldDefaults.colors(
                        unfocusedBorderColor = Color.White.copy(alpha = 0.3f),
                        focusedBorderColor = Color.White,
                        cursorColor = Color.White,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    )
                )
                
                Spacer(modifier = Modifier.height(24.dp))
                
                Button(
                    onClick = { /* Lógica Email/Pass */ },
                    modifier = Modifier.fillMaxWidth().height(56.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = ActionBlue)
                ) {
                    Text("LOGIN", fontWeight = FontWeight.Bold)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
            
            Text(text = "o", color = Color.White.copy(alpha = 0.5f))
            
            Spacer(modifier = Modifier.height(16.dp))

            // Google Button
            Button(
                onClick = onGoogleLogin,
                modifier = Modifier.fillMaxWidth().height(56.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = PrimaryNavy)
            ) {
                Text(
                    text = if (isRegister) "REGISTRATE CON GOOGLE" else "USAR GOOGLE ACCOUNT",
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}
