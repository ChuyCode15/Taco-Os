package com.tacoos.poc.presentation.ui.cajero

import android.app.Application
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.data.remote.dto.InvitationRequest
import com.tacoos.poc.presentation.layout.AppDrawerContent
import com.tacoos.poc.presentation.theme.PrimaryNavy
import com.tacoos.poc.presentation.uiState.auth.GoogleSignInState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.UUID

// --- MODELOS DE DATOS ---

data class Permission(
    val name: String,
    val isEnabled: Boolean
)

data class CashierSummary(
    val id: String,
    val nickname: String,
    val correo: String,
    val fechaEnlace: String,
    val tieneSesionAbierta: Boolean,
    val permissions: List<Permission> = listOf(
        Permission("Ventas", true),
        Permission("Inventario", false),
        Permission("Reportes", false)
    )
)

data class TeamState(
    val isLoading: Boolean = false,
    val cashiers: List<CashierSummary> = emptyList(),
    val errorMessage: String? = null
)

// --- VIEWMODELS ---

class TeamViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    private val _uiState = MutableStateFlow(TeamState())
    val uiState: StateFlow<TeamState> = _uiState.asStateFlow()

    init { loadTeam() }

    fun loadTeam() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val negocioId = GoogleSignInState.negocioId
                if (negocioId != null) {
                    // Simulación para el POC
                    _uiState.value = _uiState.value.copy(isLoading = false, cashiers = emptyList())
                } else {
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = "Negocio no identificado")
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = "Error al obtener equipo: ${e.message}")
            }
        }
    }

    fun updateNickname(cashierId: String, newNickname: String) {
        _uiState.value = _uiState.value.copy(
            cashiers = _uiState.value.cashiers.map {
                if (it.id == cashierId) it.copy(nickname = newNickname) else it
            }
        )
    }

    fun togglePermission(cashierId: String, permissionName: String) {
        _uiState.value = _uiState.value.copy(
            cashiers = _uiState.value.cashiers.map { cashier ->
                if (cashier.id == cashierId) {
                    cashier.copy(permissions = cashier.permissions.map { perm ->
                        if (perm.name == permissionName) perm.copy(isEnabled = !perm.isEnabled) else perm
                    })
                } else cashier
            }
        )
    }

    fun checkCashierLimit(): Boolean = _uiState.value.cashiers.size < 5
}

class InvitationViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    private val repository = app.repository

    fun sendWhatsAppInvitation(countryCode: String, phone: String, onResult: (Boolean, String) -> Unit) {
        viewModelScope.launch {
            // Lógica de invitación vía WhatsApp
            onResult(true, "Módulo de invitación simulado")
        }
    }
}

// --- PANTALLA PRINCIPAL ---

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TeamScreen(
    navController: NavController,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit,
    teamViewModel: TeamViewModel = viewModel(),
    invitationViewModel: InvitationViewModel = viewModel()
) {
    val teamState by teamViewModel.uiState.collectAsState()

    TeamContent(
        teamState = teamState,
        isDarkMode = isDarkMode,
        onThemeChange = onThemeChange,
        navController = navController,
        onRefresh = { teamViewModel.loadTeam() },
        checkLimit = { teamViewModel.checkCashierLimit() },
        onUpdateNickname = { id, nick -> teamViewModel.updateNickname(id, nick) },
        onTogglePermission = { id, perm -> teamViewModel.togglePermission(id, perm) },
        invitationViewModel = invitationViewModel
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TeamContent(
    teamState: TeamState,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit,
    navController: NavController,
    onRefresh: () -> Unit,
    checkLimit: () -> Boolean,
    onUpdateNickname: (String, String) -> Unit,
    onTogglePermission: (String, String) -> Unit,
    invitationViewModel: InvitationViewModel
) {
    val scope = rememberCoroutineScope()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)

    var showInvitationSheet by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState()
    val context = LocalContext.current


    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            AppDrawerContent(
                uiState = com.tacoos.poc.presentation.uiState.auth.AuthUiState(nickname = GoogleSignInState.nombre, rol = GoogleSignInState.rol),
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
                    title = { Text("MI EQUIPO", fontWeight = FontWeight.Black, fontSize = 18.sp) },
                    navigationIcon = {
                        IconButton(onClick = { scope.launch { drawerState.open() } }) {
                            Icon(Icons.Default.Menu, contentDescription = "Menú")
                        }
                    },
                    actions = {
                        IconButton(onClick = onRefresh) {
                            Icon(Icons.Default.Refresh, contentDescription = "Actualizar")
                        }
                    }
                )
            },
            floatingActionButton = {
                FloatingActionButton(
                    onClick = {
                        if (checkLimit()) {
                            showInvitationSheet = true
                        }
                    },
                    containerColor = PrimaryNavy,
                    contentColor = Color.White
                ) {
                    Icon(Icons.Default.Add, contentDescription = "Agregar Cajero")
                }
            }
        ) { padding ->
            Box(modifier = Modifier.padding(padding).fillMaxSize()) {
                if (teamState.isLoading) {
                    CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                } else if (teamState.errorMessage != null) {
                    Text(teamState.errorMessage!!, color = Color.Red, modifier = Modifier.align(Alignment.Center).padding(16.dp))
                } else if (teamState.cashiers.isEmpty()) {
                    Column(
                        modifier = Modifier.fillMaxSize(),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Button(
                            onClick = { showInvitationSheet = true },
                            modifier = Modifier.height(60.dp).fillMaxWidth(0.7f),
                            shape = RoundedCornerShape(16.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy)
                        ) {
                            Icon(Icons.Default.Add, null)
                            Spacer(Modifier.width(8.dp))
                            Text("AGREGAR CAJERO", fontWeight = FontWeight.Black)
                        }
                        Spacer(Modifier.height(16.dp))
                        Text("Aún no tienes cajeros registrados", color = Color.Gray, fontSize = 14.sp)
                    }
                } else {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(teamState.cashiers) { cashier ->
                            CashierItem(
                                cashier = cashier,
                                onUpdateNickname = { onUpdateNickname(cashier.id, it) },
                                onTogglePermission = { onTogglePermission(cashier.id, it) }
                            )
                        }
                        item { Spacer(modifier = Modifier.height(80.dp)) }
                    }
                }
            }

            if (showInvitationSheet) {
                ModalBottomSheet(
                    onDismissRequest = { showInvitationSheet = false },
                    sheetState = sheetState,
                    containerColor = MaterialTheme.colorScheme.surface,
                    dragHandle = { BottomSheetDefaults.DragHandle() }
                ) {
                    InvitationFormSheet(
                        viewModel = invitationViewModel,
                        onDismiss = { showInvitationSheet = false },
                        onNotify = { _, msg ->
                            Toast.makeText(context, msg, Toast.LENGTH_LONG).show()
                        }
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun TeamPreview() {
    TeamContent(
        teamState = TeamState(
            cashiers = listOf(
                CashierSummary("1", "Cajero 1", "cajero1@tacoos.com", "2023-09-01", true),
                CashierSummary("2", "Cajero 2", "cajero2@tacoos.com", "2023-09-02", false)
            )
        ),
        isDarkMode = false,
        onThemeChange = {},
        navController = rememberNavController(),
        onRefresh = {},
        checkLimit = { true },
        onUpdateNickname = { _, _ -> },
        onTogglePermission = { _, _ -> },
        invitationViewModel = viewModel()
    )
}

@Preview(showBackground = true, showSystemUi = true, name = "Vacio")
@Composable
fun TeamEmptyPreview() {
    TeamContent(
        teamState = TeamState(cashiers = emptyList()),
        isDarkMode = false,
        onThemeChange = {},
        navController = rememberNavController(),
        onRefresh = {},
        checkLimit = { true },
        onUpdateNickname = { _, _ -> },
        onTogglePermission = { _, _ -> },
        invitationViewModel = viewModel()
    )
}

// --- FORMULARIO DE INVITACIÓN ---

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun InvitationFormSheet(
    viewModel: InvitationViewModel,
    onDismiss: () -> Unit,
    onNotify: (Boolean, String) -> Unit
) {
    var countryCode by remember { mutableStateOf("57") }
    var phoneNumber by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(horizontal = 24.dp)
            .padding(bottom = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            "INVITAR CAJERO",
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Black,
            color = PrimaryNavy
        )

        Spacer(modifier = Modifier.height(16.dp))

        Surface(
            color = Color(0xFFE3F2FD),
            shape = RoundedCornerShape(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                text = "Módulo para enviar la invitación al cajero para agregarlo a su negocio.",
                modifier = Modifier.padding(12.dp),
                fontSize = 12.sp,
                color = Color(0xFF1976D2),
                textAlign = TextAlign.Center
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            OutlinedTextField(
                value = countryCode,
                onValueChange = { countryCode = it },
                label = { Text("País") },
                modifier = Modifier.weight(0.3f),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                prefix = { Text("+") }
            )
            Spacer(modifier = Modifier.width(8.dp))
            OutlinedTextField(
                value = phoneNumber,
                onValueChange = { phoneNumber = it },
                label = { Text("WhatsApp") },
                modifier = Modifier.weight(0.7f),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                placeholder = { Text("Número de celular") }
            )
        }

        Spacer(modifier = Modifier.height(32.dp))

        Button(
            onClick = {
                if (phoneNumber.isNotBlank()) {
                    isLoading = true
                    viewModel.sendWhatsAppInvitation(countryCode, phoneNumber) { success, msg ->
                        isLoading = false
                        onNotify(success, msg)
                        if (success) onDismiss()
                    }
                }
            },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy),
            enabled = !isLoading
        ) {
            if (isLoading) {
                CircularProgressIndicator(modifier = Modifier.size(20.dp), color = Color.White, strokeWidth = 2.dp)
            } else {
                Icon(Icons.Default.Send, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("ENVIAR INVITACIÓN")
            }
        }
    }
}

// --- COMPONENTES ---

@Composable
fun CashierItem(
    cashier: CashierSummary,
    onUpdateNickname: (String) -> Unit,
    onTogglePermission: (String) -> Unit
) {
    var isEditing by remember { mutableStateOf(false) }
    var showPermissions by remember { mutableStateOf(false) }
    var editedNickname by remember { mutableStateOf(cashier.nickname) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(modifier = Modifier.size(48.dp).clip(CircleShape).background(PrimaryNavy.copy(alpha = 0.1f)), contentAlignment = Alignment.Center) {
                    Icon(Icons.Default.Person, contentDescription = null, tint = PrimaryNavy)
                }
                Spacer(modifier = Modifier.width(16.dp))
                Column(modifier = Modifier.weight(1f).clickable { isEditing = true }) {
                    if (isEditing) {
                        OutlinedTextField(
                            value = editedNickname,
                            onValueChange = { editedNickname = it },
                            modifier = Modifier.fillMaxWidth(),
                            trailingIcon = {
                                IconButton(onClick = {
                                    onUpdateNickname(editedNickname)
                                    isEditing = false
                                }) {
                                    Icon(Icons.Default.Check, contentDescription = "Guardar", tint = Color.Green)
                                }
                            },
                            singleLine = true
                        )
                    } else {
                        Text(cashier.nickname, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    }
                    Text(cashier.correo, fontSize = 12.sp, color = Color.Gray)
                    Text("Enlazado: ${cashier.fechaEnlace}", fontSize = 10.sp, color = Color.Gray.copy(alpha = 0.7f))
                }
                val statusColor = if (cashier.tieneSesionAbierta) Color(0xFF4CAF50) else Color.Gray
                Surface(
                    color = statusColor.copy(alpha = 0.1f), shape = RoundedCornerShape(8.dp),
                    border = BorderStroke(1.dp, statusColor)
                ) {
                    Text(
                        text = if (cashier.tieneSesionAbierta) "ACTIVO" else "INACTIVO",
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                        color = statusColor, fontSize = 10.sp, fontWeight = FontWeight.Bold
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            HorizontalDivider(modifier = Modifier.fillMaxWidth(), color = Color.LightGray.copy(alpha = 0.3f))

            Row(
                modifier = Modifier.fillMaxWidth().clickable { showPermissions = !showPermissions }.padding(vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Permisos", fontWeight = FontWeight.Medium, fontSize = 14.sp)
                Icon(
                    if (showPermissions) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = null,
                    tint = Color.Gray
                )
            }

            AnimatedVisibility(visible = showPermissions) {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    cashier.permissions.forEach { permission ->
                        PermissionToggle(
                            permission = permission,
                            onToggle = { onTogglePermission(permission.name) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun PermissionToggle(permission: Permission, onToggle: () -> Unit) {
    Surface(
        onClick = onToggle,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(8.dp),
        color = if (permission.isEnabled) Color(0xFFE8F5E9) else Color(0xFFFFEBEE),
        border = BorderStroke(1.dp, if (permission.isEnabled) Color(0xFF4CAF50) else Color(0xFFE57373))
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                permission.name,
                fontSize = 13.sp,
                color = if (permission.isEnabled) Color(0xFF2E7D32) else Color(0xFFC62828),
                fontWeight = FontWeight.Bold
            )
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(if (permission.isEnabled) Color(0xFF4CAF50) else Color(0xFFF44336)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = if (permission.isEnabled) Icons.Default.Check else Icons.Default.Close,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}
