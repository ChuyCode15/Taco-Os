package com.tacoos.poc.ui.screens

import android.widget.Toast
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import com.tacoos.poc.ui.theme.SuccessGreen
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

// Modelos de datos
data class POSSale(val id: String, val amount: Double, val method: String, val status: String, val timestamp: Long = System.currentTimeMillis())
data class POSItem(val name: String, val price: Double, val category: String, var quantity: Int = 0)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SalesScreen(
    navController: NavController, 
    isDarkMode: Boolean, 
    onThemeChange: (Boolean) -> Unit,
    viewModel: SalesViewModel = viewModel()
) {
    val scope = rememberCoroutineScope()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val context = LocalContext.current
    
    var isShiftStarted by remember { mutableStateOf(false) }
    val sales = remember { mutableStateListOf<POSSale>() }
    var showNewSalePopup by remember { mutableStateOf(false) }
    var showCortePopup by remember { mutableStateOf(false) }

    // Simulación de datos de usuario (esto debería venir de tu Auth/ViewModel)
    val userName = "Admin Taco-Os" 

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            AppDrawerContent(
                userName = userName,
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
                    title = { Text("VENTAS", fontWeight = FontWeight.Black) },
                    navigationIcon = {
                        IconButton(onClick = { scope.launch { drawerState.open() } }) {
                            Icon(Icons.Default.Menu, contentDescription = "Menú")
                        }
                    }
                )
            }
        ) { padding ->
            Column(modifier = Modifier.fillMaxSize().padding(padding)) {
                val currentTime = SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date())
                Row(modifier = Modifier.fillMaxWidth().background(Color.LightGray.copy(alpha = 0.1f)).padding(12.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(currentTime, fontWeight = FontWeight.Bold, color = Color.Gray)
                    Text("CAJERO ACTIVO", fontWeight = FontWeight.Bold, color = ActionBlue)
                }

                if (!isShiftStarted) {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Button(onClick = { isShiftStarted = true }, shape = RoundedCornerShape(20.dp), colors = ButtonDefaults.buttonColors(containerColor = ActionBlue)) {
                            Text("ABRIR CAJA", fontWeight = FontWeight.Bold)
                        }
                    }
                } else {
                    Column(modifier = Modifier.weight(1f).padding(16.dp)) {
                        Text("REGISTRO DE HOY (LOCAL)", style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold)
                        Spacer(Modifier.height(8.dp))
                        
                        Surface(modifier = Modifier.weight(1f), shape = RoundedCornerShape(16.dp), color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f)) {
                            LazyColumn {
                                items(sales) { sale -> SaleRow(sale) }
                            }
                        }

                        Spacer(Modifier.height(16.dp))
                        
                        // RESTAURADO: Botón original grande de NUEVA VENTA
                        Button(
                            onClick = { showNewSalePopup = true },
                            modifier = Modifier.fillMaxWidth().height(65.dp),
                            shape = RoundedCornerShape(16.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = SuccessGreen)
                        ) {
                            Icon(Icons.Default.Add, null)
                            Spacer(Modifier.width(8.dp))
                            Text("NUEVA VENTA", fontSize = 18.sp, fontWeight = FontWeight.Black)
                        }
                        
                        TextButton(
                            onClick = { showCortePopup = true },
                            modifier = Modifier.align(Alignment.CenterHorizontally).padding(top = 8.dp)
                        ) {
                            Text("CERRAR CORTE", color = Color.Gray, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }
        }
    }

    if (showNewSalePopup) {
        NewSaleDialog(
            onDismiss = { showNewSalePopup = false },
            onConfirm = { amount, method, items ->
                viewModel.saveSale(amount, items)
                sales.add(0, POSSale(UUID.randomUUID().toString(), amount, method, "Cobrada"))
                showNewSalePopup = false
                Toast.makeText(context, "Venta guardada", Toast.LENGTH_SHORT).show()
            }
        )
    }

    if (showCortePopup) {
        CorteDialog(sales = sales, onDismiss = { showCortePopup = false }, onConfirm = { isShiftStarted = false; sales.clear(); showCortePopup = false })
    }
}

@Composable
fun AppDrawerContent(
    userName: String,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit,
    navController: NavController,
    onClose: () -> Unit
) {
    ModalDrawerSheet(modifier = Modifier.width(300.dp)) {
        Column(modifier = Modifier.fillMaxSize()) {
            // HEADER: Foto ovalada y nombre
            Box(modifier = Modifier.fillMaxWidth().background(PrimaryNavy).padding(top = 48.dp, start = 24.dp, end = 24.dp, bottom = 24.dp)) {
                Column {
                    // Ícono de perfil ovalado (Simulando foto de Google)
                    Surface(
                        modifier = Modifier
                            .size(70.dp)
                            .clip(RoundedCornerShape(25.dp)), // Forma ovalada
                        color = Color.White.copy(alpha = 0.2f)
                    ) {
                        Icon(Icons.Default.Person, null, modifier = Modifier.padding(12.dp), tint = Color.White)
                    }
                    Spacer(Modifier.height(16.dp))
                    Text(userName, color = Color.White, fontWeight = FontWeight.Black, fontSize = 20.sp)
                    Text("Administrador", color = Color.White.copy(alpha = 0.6f), fontSize = 14.sp)
                }
            }

            Spacer(Modifier.height(16.dp))

            // OPCIONES PRINCIPALES
            NavigationDrawerItem(
                label = { Text("Dashboard", fontWeight = FontWeight.Bold) },
                selected = false,
                onClick = { onClose(); navController.navigate("dashboard") },
                icon = { Icon(Icons.Default.Dashboard, null) },
                modifier = Modifier.padding(horizontal = 12.dp)
            )
            NavigationDrawerItem(
                label = { Text("Ventas", fontWeight = FontWeight.Bold) },
                selected = false,
                onClick = { onClose(); navController.navigate("sales") },
                icon = { Icon(Icons.Default.PointOfSale, null) },
                modifier = Modifier.padding(horizontal = 12.dp)
            )
            NavigationDrawerItem(
                label = { Text("Reportes", fontWeight = FontWeight.Bold) },
                selected = false,
                onClick = { onClose(); navController.navigate("reports") },
                icon = { Icon(Icons.Default.BarChart, null) },
                modifier = Modifier.padding(horizontal = 12.dp)
            )
            NavigationDrawerItem(
                label = { Text("Ajustes", fontWeight = FontWeight.Bold) },
                selected = false,
                onClick = { onClose(); navController.navigate("settings") },
                icon = { Icon(Icons.Default.Settings, null) },
                modifier = Modifier.padding(horizontal = 12.dp)
            )

            Divider(modifier = Modifier.padding(vertical = 12.dp, horizontal = 16.dp))

            // MODO OSCURO
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(if(isDarkMode) Icons.Default.DarkMode else Icons.Default.LightMode, null, tint = Color.Gray)
                    Spacer(Modifier.width(12.dp))
                    Text("Modo Oscuro", fontWeight = FontWeight.Bold)
                }
                Switch(checked = isDarkMode, onCheckedChange = onThemeChange)
            }

            Spacer(modifier = Modifier.weight(1f))

            // CERRAR SESIÓN (AL FINAL Y EN ROJO)
            Text(
                "CERRAR SESIÓN", 
                modifier = Modifier
                    .padding(24.dp)
                    .clickable { 
                        onClose()
                        navController.navigate("login") { popUpTo(0) } 
                    }, 
                color = Color.Red, 
                fontWeight = FontWeight.Black,
                letterSpacing = 1.sp
            )
        }
    }
}

@Composable
fun SaleRow(sale: POSSale) {
    Row(modifier = Modifier.fillMaxWidth().padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(if(sale.method == "Efectivo") SuccessGreen else ActionBlue))
        Spacer(Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text("Venta #${sale.id.take(4)}", fontWeight = FontWeight.Bold, fontSize = 14.sp)
            Text(sale.method, fontSize = 12.sp, color = Color.Gray)
        }
        Text("$${sale.amount}", fontWeight = FontWeight.Black, color = PrimaryNavy)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewSaleDialog(onDismiss: () -> Unit, onConfirm: (Double, String, List<POSItem>) -> Unit) {
    var step by remember { mutableStateOf(1) }
    val cart = remember { mutableStateListOf<POSItem>() }
    var selectedCategory by remember { mutableStateOf("") }
    var selectedProduct by remember { mutableStateOf<POSItem?>(null) }
    var qtyInput by remember { mutableStateOf("1") }
    var paymentMethod by remember { mutableStateOf("Efectivo") }

    val products = listOf(
        POSItem("Taco Pastor", 25.0, "Comidas"),
        POSItem("Taco Bistec", 30.0, "Comidas"),
        POSItem("Gringa", 65.0, "Comidas"),
        POSItem("Coca 600ml", 22.0, "Bebidas"),
        POSItem("Agua Fresca", 20.0, "Bebidas"),
        POSItem("Flan Casero", 45.0, "Postres")
    )

    AlertDialog(
        onDismissRequest = onDismiss,
        properties = androidx.compose.ui.window.DialogProperties(usePlatformDefaultWidth = false),
        modifier = Modifier.fillMaxSize().padding(16.dp),
        content = {
            Surface(modifier = Modifier.fillMaxSize(), shape = RoundedCornerShape(24.dp), color = Color.White) {
                Column(modifier = Modifier.padding(24.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        if(step > 1) IconButton(onClick = { step-- }) { Icon(Icons.Default.ArrowBack, null) }
                        Text("Nueva Venta", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Black)
                        Spacer(Modifier.weight(1f))
                        IconButton(onClick = onDismiss) { Icon(Icons.Default.Close, null) }
                    }
                    
                    Box(modifier = Modifier.weight(1f).padding(vertical = 16.dp)) {
                        when(step) {
                            1 -> {
                                if(cart.isEmpty()) {
                                    Box(modifier = Modifier.fillMaxSize().clickable { step = 2 }, contentAlignment = Alignment.Center) {
                                        Text("+ AGREGAR PRODUCTO", fontWeight = FontWeight.Bold, color = ActionBlue)
                                    }
                                } else {
                                    LazyColumn {
                                        items(cart) { item ->
                                            Row(modifier = Modifier.fillMaxWidth().padding(8.dp)) {
                                                Text("${item.quantity}x ${item.name}", modifier = Modifier.weight(1f))
                                                Text("$${item.price * item.quantity}")
                                            }
                                        }
                                    }
                                }
                            }
                            2 -> {
                                Column {
                                    CategoryBtn("Comidas") { selectedCategory = "Comidas"; step = 3 }
                                    CategoryBtn("Bebidas") { selectedCategory = "Bebidas"; step = 3 }
                                    CategoryBtn("Postres") { selectedCategory = "Postres"; step = 3 }
                                }
                            }
                            3 -> {
                                LazyColumn {
                                    items(products.filter { it.category == selectedCategory }) { prod ->
                                        Row(modifier = Modifier.fillMaxWidth().clickable { selectedProduct = prod; step = 4 }.padding(16.dp)) {
                                            Text(prod.name, fontWeight = FontWeight.Bold)
                                            Spacer(Modifier.weight(1f))
                                            Text("$${prod.price}")
                                        }
                                    }
                                }
                            }
                            4 -> {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(selectedProduct?.name ?: "", fontSize = 24.sp, fontWeight = FontWeight.Black)
                                    Spacer(Modifier.height(16.dp))
                                    OutlinedTextField(
                                        value = qtyInput,
                                        onValueChange = { qtyInput = it },
                                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                        label = { Text("Cantidad") },
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    Spacer(Modifier.height(24.dp))
                                    Button(onClick = { 
                                        selectedProduct?.let { 
                                            val newItem = it.copy(quantity = qtyInput.toIntOrNull() ?: 1)
                                            cart.add(newItem)
                                            step = 1
                                            qtyInput = "1"
                                        }
                                    }, modifier = Modifier.fillMaxWidth()) { Text("AGREGAR AL CARRITO") }
                                }
                            }
                            5 -> {
                                val total = cart.sumOf { it.price * it.quantity }
                                Column {
                                    Text("TOTAL A COBRAR", fontSize = 12.sp, color = Color.Gray)
                                    Text("$${total}", fontSize = 48.sp, fontWeight = FontWeight.Black, color = PrimaryNavy)
                                    Spacer(Modifier.height(32.dp))
                                    Row {
                                        MethodBtn("Efectivo", paymentMethod == "Efectivo") { paymentMethod = "Efectivo" }
                                        Spacer(Modifier.width(12.dp))
                                        MethodBtn("Tarjeta", paymentMethod == "Tarjeta") { paymentMethod = "Tarjeta" }
                                    }
                                    Spacer(modifier = Modifier.weight(1f))
                                    Button(onClick = { onConfirm(total, paymentMethod, cart.toList()) }, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(16.dp)) {
                                        Text("CONFIRMAR PAGO", fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }
                    }
                    
                    if(step == 1 && cart.isNotEmpty()) {
                        Button(onClick = { step = 5 }, modifier = Modifier.fillMaxWidth().height(60.dp)) {
                            Text("COBRAR $${cart.sumOf { it.price * it.quantity }}")
                        }
                        Spacer(Modifier.height(8.dp))
                        TextButton(onClick = { step = 2 }, modifier = Modifier.fillMaxWidth()) { Text("+ OTRO PRODUCTO") }
                    }
                }
            }
        }
    )
}

@Composable
fun CategoryBtn(name: String, onClick: () -> Unit) {
    Card(modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp).clickable { onClick() }) {
        Text(name, modifier = Modifier.padding(24.dp), fontWeight = FontWeight.Bold)
    }
}

@Composable
fun RowScope.MethodBtn(name: String, selected: Boolean, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        colors = ButtonDefaults.buttonColors(containerColor = if(selected) ActionBlue else Color.LightGray),
        modifier = Modifier.height(60.dp).weight(1f),
        shape = RoundedCornerShape(12.dp)
    ) { Text(name, fontWeight = FontWeight.Bold) }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CorteDialog(sales: List<POSSale>, onDismiss: () -> Unit, onConfirm: () -> Unit) {
    val total = sales.sumOf { it.amount }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Cerrar Corte", fontWeight = FontWeight.Black) },
        text = { Text("Total de ventas hoy: $${total}\n\n¿Estás seguro de cerrar el turno?") },
        confirmButton = { Button(onClick = onConfirm, colors = ButtonDefaults.buttonColors(containerColor = Color.Red)) { Text("CERRAR") } },
        dismissButton = { TextButton(onClick = onDismiss) { Text("CANCELAR") } }
    )
}
