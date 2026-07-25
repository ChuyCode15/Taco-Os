package com.tacoos.poc.ui.screens

import android.app.Application
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.remote.BusinessRequest
import com.tacoos.poc.ui.components.TacoDialog
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import com.tacoos.poc.ui.theme.SuccessGreen
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class SettingsUiState(
    val isLoading: Boolean = false,
    val businessName: String = "",
    val address: String = "",
    val phone: String = "",
    val footerMessage: String = "¡Gracias por su compra!",
    val pendingSalesCount: Int = 0,
    val errorMessage: String? = null
)

class SettingsViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    init {
        loadSettingsData()
    }

    fun loadSettingsData() {
        viewModelScope.launch {
            val negocioId = GoogleSignInState.negocioId
            if (negocioId == null) {
                _uiState.value = _uiState.value.copy(errorMessage = "Sesión no válida")
                return@launch
            }
            _uiState.value = _uiState.value.copy(isLoading = true)
            try {
                // 1. Cargar Datos del Negocio desde el servidor
                val business = app.repository.getBusinessDetails(negocioId)
                
                // 2. Cargar Ventas Pendientes (Local)
                val allSales = app.database.saleDao().getAllSales()
                val pending = allSales.count { !it.isSynced && it.status == "ACTIVE" }

                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    businessName = business.nombre,
                    address = business.direccion,
                    phone = business.telefono,
                    pendingSalesCount = pending
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = "Error al cargar: ${e.message}")
            }
        }
    }

    fun updateBusiness(nombre: String, direccion: String, telefono: String) {
        viewModelScope.launch {
            val negocioId = GoogleSignInState.negocioId ?: return@launch
            try {
                app.repository.updateBusiness(
                    negocioId, 
                    BusinessRequest(nombre, direccion, telefono)
                )
                loadSettingsData()
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(errorMessage = "Error al actualizar")
            }
        }
    }

    fun updateFooterMessage(newMessage: String) {
        _uiState.value = _uiState.value.copy(footerMessage = newMessage)
    }

    fun syncNow() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            try {
                app.repository.syncPendingSales()
                loadSettingsData() // Refrescar contador tras sincronizar
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = "Error en sincronización")
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    navController: NavController,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit,
    viewModel: SettingsViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val scrollState = rememberScrollState()
    val context = LocalContext.current
    
    var showEditBusinessDialog by remember { mutableStateOf(false) }
    var showEditTicketDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("AJUSTES", fontWeight = FontWeight.Black) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, null)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
            )
        }
    ) { padding ->
        if (uiState.isLoading && uiState.businessName.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = ActionBlue)
            }
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .verticalScroll(scrollState)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                // SECCIÓN 1: PERFIL DEL NEGOCIO
                SettingsSection(title = "PERFIL DEL NEGOCIO", icon = Icons.Default.Store) {
                    SettingsItem(label = "Nombre", value = uiState.businessName) { showEditBusinessDialog = true }
                    SettingsItem(label = "Dirección", value = uiState.address) { showEditBusinessDialog = true }
                    SettingsItem(label = "Teléfono", value = uiState.phone) { showEditBusinessDialog = true }
                }

                // SECCIÓN 2: CONFIGURACIÓN DE TICKETS
                SettingsSection(title = "CONFIGURACIÓN DE TICKETS", icon = Icons.Default.ConfirmationNumber) {
                    SettingsItem(
                        label = "Mensaje al pie (Footer)", 
                        value = uiState.footerMessage
                    ) { showEditTicketDialog = true }
                }

                // SECCIÓN 3: ESTADO DE SINCRONIZACIÓN
                SettingsSection(title = "SINCRONIZACIÓN", icon = Icons.Default.CloudSync) {
                    SettingsActionItem(
                        label = "Ventas Pendientes", 
                        description = "${uiState.pendingSalesCount} registros sin subir",
                        icon = Icons.Default.Sync,
                        actionLabel = "SINCRONIZAR AHORA"
                    ) {
                        viewModel.syncNow()
                        Toast.makeText(context, "Sincronizando...", Toast.LENGTH_SHORT).show()
                    }
                }

                Spacer(modifier = Modifier.height(32.dp))
                
                Text(
                    "Taco-Os POS v1.0.0-POC", 
                    modifier = Modifier.align(Alignment.CenterHorizontally),
                    color = Color.Gray,
                    fontSize = 12.sp
                )
                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }

    // Diálogo Edición Negocio
    if (showEditBusinessDialog) {
        EditBusinessDialog(
            currentName = uiState.businessName,
            currentAddress = uiState.address,
            currentPhone = uiState.phone,
            onDismiss = { showEditBusinessDialog = false },
            onSave = { n, d, t ->
                viewModel.updateBusiness(n, d, t)
                showEditBusinessDialog = false
            }
        )
    }

    // Diálogo Edición Ticket
    if (showEditTicketDialog) {
        var tempFooter by remember { mutableStateOf(uiState.footerMessage) }
        TacoDialog(
            title = "Mensaje del Ticket",
            onDismiss = { showEditTicketDialog = false },
            onConfirm = {
                viewModel.updateFooterMessage(tempFooter)
                showEditTicketDialog = false
            }
        ) {
            OutlinedTextField(
                value = tempFooter, 
                onValueChange = { tempFooter = it },
                label = { Text("Mensaje de agradecimiento") },
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

@Composable
fun EditBusinessDialog(
    currentName: String,
    currentAddress: String,
    currentPhone: String,
    onDismiss: () -> Unit,
    onSave: (String, String, String) -> Unit
) {
    var name by remember { mutableStateOf(currentName) }
    var address by remember { mutableStateOf(currentAddress) }
    var phone by remember { mutableStateOf(currentPhone) }

    TacoDialog(
        title = "Editar Negocio",
        onDismiss = onDismiss,
        onConfirm = { onSave(name, address, phone) }
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            OutlinedTextField(value = name, onValueChange = { name = it }, label = { Text("Nombre") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = address, onValueChange = { address = it }, label = { Text("Dirección") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = phone, onValueChange = { phone = it }, label = { Text("Teléfono") }, modifier = Modifier.fillMaxWidth())
        }
    }
}

@Composable
fun SettingsSection(title: String, icon: ImageVector, content: @Composable ColumnScope.() -> Unit) {
    Column {
        Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(bottom = 12.dp)) {
            Icon(icon, null, tint = ActionBlue, modifier = Modifier.size(20.dp))
            Spacer(Modifier.width(8.dp))
            Text(title, fontWeight = FontWeight.Black, color = PrimaryNavy, letterSpacing = 1.sp, fontSize = 12.sp)
        }
        Surface(
            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
            shape = RoundedCornerShape(16.dp)
        ) {
            Column(modifier = Modifier.padding(4.dp)) {
                content()
            }
        }
    }
}

@Composable
fun SettingsItem(label: String, value: String, valueColor: Color = Color.Gray, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(label, fontWeight = FontWeight.Medium, fontSize = 14.sp)
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = value, 
                color = valueColor, 
                fontSize = 14.sp, 
                modifier = Modifier.widthIn(max = 180.dp),
                maxLines = 1
            )
            Icon(Icons.Default.ChevronRight, null, tint = Color.LightGray, modifier = Modifier.size(20.dp))
        }
    }
}

@Composable
fun SettingsActionItem(label: String, description: String, icon: ImageVector, actionLabel: String = "", onClick: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .background(ActionBlue.copy(alpha = 0.1f), RoundedCornerShape(8.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(icon, null, tint = ActionBlue, modifier = Modifier.size(20.dp))
            }
            Spacer(Modifier.width(16.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(label, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                Text(description, color = Color.Gray, fontSize = 12.sp)
            }
        }
        if (actionLabel.isNotEmpty()) {
            Spacer(Modifier.height(12.dp))
            Button(
                onClick = onClick, 
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text(actionLabel, fontWeight = FontWeight.Bold)
            }
        }
    }
}
