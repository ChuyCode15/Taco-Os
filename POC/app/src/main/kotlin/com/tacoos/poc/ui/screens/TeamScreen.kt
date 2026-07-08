package com.tacoos.poc.ui.screens

import android.app.Application
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.data.remote.InvitationRequest
import com.tacoos.poc.data.remote.InvitationResponse
import com.tacoos.poc.ui.theme.PrimaryNavy
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.UUID

// --- MODELOS DE DATOS ---

data class CashierSummary(
    val id: String,
    val nickname: String,
    val correo: String,
    val fechaEnlace: String,
    val tieneSesionAbierta: Boolean
)

data class TeamState(
    val isLoading: Boolean = false,
    val cashiers: List<CashierSummary> = emptyList(),
    val errorMessage: String? = null
)

data class InvitationState(
    val invitation: InvitationResponse? = null,
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

// --- VIEWMODELS ---

class TeamViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(TeamState())
    val uiState: StateFlow<TeamState> = _uiState.asStateFlow()

    init { loadTeam() }

    fun loadTeam() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                delay(800)
                val mockCashiers = listOf(
                    CashierSummary("1", "Cajero 1", "cajero1@tacoos.com", "2023-11-15", true),
                    CashierSummary("2", "Cajero 2", "cajero2@tacoos.com", "2023-11-16", false)
                )
                _uiState.value = _uiState.value.copy(isLoading = false, cashiers = mockCashiers)
            } catch (_: Exception) {
                _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = "Error al obtener equipo")
            }
        }
    }

    fun checkCashierLimit(): Boolean = _uiState.value.cashiers.size < 5
}

class InvitationViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    private val repository = TacoRepository(app.api, app.database)

    private val _uiState = MutableStateFlow(InvitationState())
    val uiState: StateFlow<InvitationState> = _uiState.asStateFlow()

    fun generateInvitation() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            val currentUser = repository.getCurrentUser()
            val negocioId = currentUser?.negocioId
            val duenoId = currentUser?.id

            if (negocioId != null && duenoId != null) {
                try {
                    val response = app.api.generateInvitation(
                        InvitationRequest(
                            negocioId = UUID.fromString(negocioId),
                            duenoId = UUID.fromString(duenoId)
                        )
                    )
                    _uiState.value = _uiState.value.copy(invitation = response, isLoading = false)
                } catch (e: Exception) {
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = "Error: ${e.message}")
                }
            } else {
                _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = "Sesión no válida")
            }
        }
    }
}

// --- PANTALLA PRINCIPAL ---

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TeamScreen(
    navController: NavController,
    teamViewModel: TeamViewModel = viewModel(),
    invitationViewModel: InvitationViewModel = viewModel()
) {
    val teamState by teamViewModel.uiState.collectAsState()
    var showInvitationSheet by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("MI EQUIPO", fontWeight = FontWeight.Black, fontSize = 18.sp) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Atrás")
                    }
                },
                actions = {
                    IconButton(onClick = { teamViewModel.loadTeam() }) {
                        Icon(Icons.Default.Refresh, contentDescription = "Actualizar")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = {
                    if (teamViewModel.checkCashierLimit()) {
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
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(teamState.cashiers) { cashier ->
                        CashierItem(cashier)
                    }
                    item { Spacer(modifier = Modifier.height(80.dp)) }
                }
            }
        }

        // --- POP-UP DE INVITACIÓN (MODAL BOTTOM SHEET) ---
        if (showInvitationSheet) {
            ModalBottomSheet(
                onDismissRequest = { showInvitationSheet = false },
                sheetState = sheetState,
                containerColor = MaterialTheme.colorScheme.surface,
                dragHandle = { BottomSheetDefaults.DragHandle() }
            ) {
                InvitationSheetContent(
                    viewModel = invitationViewModel,
                    onDismiss = { showInvitationSheet = false }
                )
            }
        }
    }
}

// --- CONTENIDO DEL POP-UP ---

@Composable
fun InvitationSheetContent(
    viewModel: InvitationViewModel,
    onDismiss: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val clipboardManager = LocalClipboardManager.current

    LaunchedEffect(Unit) {
        viewModel.generateInvitation()
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(horizontal = 24.dp)
            .padding(bottom = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            "INVITAR A EQUIPO",
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Black,
            color = PrimaryNavy
        )
        
        Spacer(modifier = Modifier.height(24.dp))

        if (uiState.isLoading) {
            Box(modifier = Modifier.height(300.dp), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = PrimaryNavy)
            }
        } else if (uiState.errorMessage != null) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(uiState.errorMessage!!, color = Color.Red, textAlign = TextAlign.Center)
                Spacer(modifier = Modifier.height(16.dp))
                Button(onClick = { viewModel.generateInvitation() }) {
                    Text("Reintentar")
                }
            }
        } else uiState.invitation?.let { invitation ->
            Text("CÓDIGO DE VINCULACIÓN", style = MaterialTheme.typography.labelLarge, color = Color.Gray)
            
            Spacer(modifier = Modifier.height(12.dp))
            
            Surface(
                color = MaterialTheme.colorScheme.surfaceVariant,
                shape = RoundedCornerShape(16.dp),
                modifier = Modifier.clickable { clipboardManager.setText(AnnotatedString(invitation.codigo)) }
            ) {
                Row(modifier = Modifier.padding(horizontal = 24.dp, vertical = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = invitation.codigo,
                        style = MaterialTheme.typography.headlineLarge,
                        fontWeight = FontWeight.Black,
                        letterSpacing = 4.sp,
                        color = PrimaryNavy
                    )
                    Spacer(modifier = Modifier.width(16.dp))
                    Icon(Icons.Default.ContentCopy, contentDescription = "Copiar", tint = Color.Gray)
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Box(
                modifier = Modifier.size(180.dp).background(Color.White, RoundedCornerShape(16.dp)).padding(16.dp),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.QrCode2, contentDescription = "QR", modifier = Modifier.fillMaxSize(), tint = Color.Black)
            }
            
            Spacer(modifier = Modifier.height(20.dp))
            
            Text(
                "Escanea el QR o ingresa el código en la App del cajero",
                textAlign = TextAlign.Center, fontSize = 13.sp, color = Color.Gray
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                "Expira en ${invitation.expiraEnMinutos} minutos",
                fontWeight = FontWeight.Bold, color = Color.Red.copy(alpha = 0.7f), fontSize = 11.sp
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Button(
                onClick = { onDismiss() },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy)
            ) {
                Icon(Icons.Default.Share, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("COMPARTIR CÓDIGO")
            }
        }
    }
}

// --- COMPONENTES ---

@Composable
fun CashierItem(cashier: CashierSummary) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
    ) {
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(modifier = Modifier.size(48.dp).clip(CircleShape).background(PrimaryNavy.copy(alpha = 0.1f)), contentAlignment = Alignment.Center) {
                Icon(Icons.Default.Person, contentDescription = null, tint = PrimaryNavy)
            }
            Spacer(modifier = Modifier.width(16.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(cashier.nickname, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Text(cashier.correo, fontSize = 12.sp, color = Color.Gray)
                Text("Enlazado: ${cashier.fechaEnlace}", fontSize = 10.sp, color = Color.Gray.copy(alpha = 0.7f))
            }
            val statusColor = if (cashier.tieneSesionAbierta) Color(0xFF4CAF50) else Color.Gray
            Surface(
                color = statusColor.copy(alpha = 0.1f), shape = RoundedCornerShape(8.dp),
                border = androidx.compose.foundation.BorderStroke(1.dp, statusColor)
            ) {
                Text(
                    text = if (cashier.tieneSesionAbierta) "ACTIVO" else "INACTIVO",
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                    color = statusColor, fontSize = 10.sp, fontWeight = FontWeight.Bold
                )
            }
        }
    }
}
