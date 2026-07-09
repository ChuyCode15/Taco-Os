package com.tacoos.poc.ui.screens

import android.app.TimePickerDialog
import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.animation.core.*
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
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import com.tacoos.poc.ui.theme.SuccessGreen
import com.tacoos.poc.ui.theme.WarningAmber
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

// Singleton para persistencia del corte en el POC
object ShiftManager {
    var isShiftOpen by mutableStateOf(false)
    var openTimestamp by mutableStateOf(0L)
    var fondoCaja by mutableStateOf(0.0)
    var currentCashier by mutableStateOf("Desconocido")
    
    // Listas persistentes durante la sesión
    val sales = mutableStateListOf<POSSale>()
    val expenses = mutableStateListOf<POSExpense>()
}

data class POSSale(
    val id: String,
    val amount: Double,
    val method: String,
    val status: String,
    val timestamp: Long = System.currentTimeMillis(),
    val items: List<SaleItemSummary> = emptyList()
)

data class SaleItemSummary(
    val productName: String,
    val totalQuantity: Int,
    val totalPrice: Double
)

data class POSItem(
    val name: String,
    val price: Double,
    val category: String,
    var quantity: Int = 0
)

data class POSExpense(
    val id: String = UUID.randomUUID().toString(),
    val detail: String,
    val amount: Double,
    val cashier: String,
    val timestamp: Long = System.currentTimeMillis()
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SalesScreen(navController: NavController, isDarkMode: Boolean, onThemeChange: (Boolean) -> Unit) {
    val scope = rememberCoroutineScope()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val context = LocalContext.current
    
    var selectedSale by remember { mutableStateOf<POSSale?>(null) }
    
    var showOpeningDialog by remember { mutableStateOf(false) }
    var showNewSalePopup by remember { mutableStateOf(false) }
    var showCortePopup by remember { mutableStateOf(false) }
    var showExpensePopup by remember { mutableStateOf(false) }
    
    // Alertas de éxito/error de transacción
    var transactionSuccessMessage by remember { mutableStateOf<String?>(null) }
    var transactionErrorMessage by remember { mutableStateOf<String?>(null) }

    val dateFormat = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault())

    // Auto-cierre de alertas
    LaunchedEffect(transactionSuccessMessage) {
        if (transactionSuccessMessage != null) {
            delay(1500)
            transactionSuccessMessage = null
        }
    }
    LaunchedEffect(transactionErrorMessage) {
        if (transactionErrorMessage != null) {
            delay(1500)
            transactionErrorMessage = null
        }
    }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(
                modifier = Modifier.width(300.dp),
                drawerContainerColor = MaterialTheme.colorScheme.surface,
                drawerShape = RoundedCornerShape(topEnd = 24.dp, bottomEnd = 24.dp)
            ) {
                Spacer(Modifier.height(48.dp))
                Row(modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("MENU", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Black)
                    AppleToggle(checked = isDarkMode, onCheckedChange = onThemeChange)
                }
                Spacer(Modifier.height(16.dp))
                NavigationDrawerItem(label = { Text("Ajustes") }, selected = false, onClick = { scope.launch { drawerState.close() }; navController.navigate("settings") }, icon = { Icon(Icons.Default.Settings, null) })
                Spacer(modifier = Modifier.weight(1f))
                Text("Cerrar Sesión", modifier = Modifier.padding(24.dp).clickable { navController.navigate("login") { popUpTo(0) } }, color = Color.Red, fontWeight = FontWeight.Black)
            }
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("VENTAS", fontWeight = FontWeight.Black) },
                    navigationIcon = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            IconButton(onClick = { navController.popBackStack() }) { Icon(Icons.Default.ArrowBack, null) }
                            IconButton(onClick = { scope.launch { drawerState.open() } }) { Icon(Icons.Default.Menu, null) }
                        }
                    }
                )
            }
        ) { padding ->
            Box(modifier = Modifier.fillMaxSize().padding(padding)) {
                Column(modifier = Modifier.fillMaxSize()) {
                    // Info Bar
                    Row(
                        modifier = Modifier.fillMaxWidth().background(Color.LightGray.copy(alpha = 0.1f)).padding(12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date()), fontWeight = FontWeight.Bold, color = Color.Gray)
                        Text(GoogleSignInState.nombre.ifEmpty { "Usuario" }, fontWeight = FontWeight.Bold, color = ActionBlue)
                    }

                    if (!ShiftManager.isShiftOpen) {
                        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(Icons.Default.Lock, null, modifier = Modifier.size(100.dp), tint = Color.LightGray.copy(alpha = 0.5f))
                                Spacer(Modifier.height(16.dp))
                                Text("LA CAJA ESTÁ CERRADA", fontWeight = FontWeight.Black, color = Color.Gray)
                                Spacer(Modifier.height(32.dp))
                                Button(onClick = { showOpeningDialog = true }, shape = RoundedCornerShape(20.dp), modifier = Modifier.height(60.dp).fillMaxWidth(0.6f)) {
                                    Text("ABRIR CAJA", fontWeight = FontWeight.Black)
                                }
                            }
                        }
                    } else {
                        Column(modifier = Modifier.weight(1f).padding(16.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text("CORTE ACTIVO", style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold)
                                Spacer(Modifier.width(8.dp))
                                Box(modifier = Modifier.size(8.dp).clip(CircleShape).background(SuccessGreen))
                            }
                            Text("Abierta: ${dateFormat.format(Date(ShiftManager.openTimestamp))}", fontSize = 10.sp, color = Color.Gray)
                            Spacer(Modifier.height(16.dp))
                            Surface(
                                modifier = Modifier.weight(1f).fillMaxWidth(),
                                shape = RoundedCornerShape(24.dp),
                                color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                                border = androidx.compose.foundation.BorderStroke(1.dp, Color.LightGray.copy(alpha = 0.3f))
                            ) {
                                if (ShiftManager.sales.isEmpty()) {
                                    Box(contentAlignment = Alignment.Center) { Text("Sin ventas en este corte", color = Color.Gray) }
                                } else {
                                    LazyColumn {
                                        items(ShiftManager.sales) { sale ->
                                            SaleRow(sale, isSelected = selectedSale?.id == sale.id) { selectedSale = sale }
                                        }
                                    }
                                }
                            }
                            Row(modifier = Modifier.fillMaxWidth().padding(vertical = 16.dp), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.CenterVertically) {
                                ActionButton(Icons.Default.Close, "Cancelar", Color.Red) {
                                    selectedSale?.let { 
                                        if(System.currentTimeMillis() - it.timestamp < 300000) {
                                            ShiftManager.sales[ShiftManager.sales.indexOf(it)] = it.copy(status = "Cancelada")
                                            selectedSale = null
                                        } else {
                                            Toast.makeText(context, "Registro inmutable (> 5 min)", Toast.LENGTH_SHORT).show()
                                        }
                                    }
                                }
                                
                                // BOTON GASTO (Implementación solicitada entre cancelar y venta)
                                ActionButton(Icons.Default.ShoppingCart, "Gasto", WarningAmber) {
                                    showExpensePopup = true
                                }
                                
                                ActionButton(Icons.Default.Add, "Venta", SuccessGreen) { showNewSalePopup = true }
                            }
                            Button(onClick = { showCortePopup = true }, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(16.dp), colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy)) {
                                Text("CERRAR CORTE", fontWeight = FontWeight.Black)
                            }
                        }
                    }
                }
                
                // Alert de éxito transaccional
                if (transactionSuccessMessage != null) {
                    Box(modifier = Modifier.fillMaxWidth().height(50.dp).background(SuccessGreen).align(Alignment.TopCenter), contentAlignment = Alignment.Center) {
                        Text(transactionSuccessMessage!!, color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
                
                // Alert de error transaccional
                if (transactionErrorMessage != null) {
                    Box(modifier = Modifier.fillMaxWidth().height(50.dp).background(Color.Red).align(Alignment.TopCenter), contentAlignment = Alignment.Center) {
                        Text(transactionErrorMessage!!, color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }

    if (showOpeningDialog) {
        var fondoInput by remember { mutableStateOf("") }
        AlertDialog(
            onDismissRequest = { showOpeningDialog = false },
            title = { Text("Apertura de Caja", fontWeight = FontWeight.Black) },
            text = {
                Column {
                    Text("¿Hay fondo de caja?")
                    Spacer(Modifier.height(16.dp))
                    OutlinedTextField(
                        value = fondoInput,
                        onValueChange = { if(it.all { c -> c.isDigit() }) fondoInput = it },
                        label = { Text("Cantidad") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            },
            confirmButton = {
                Button(onClick = {
                    ShiftManager.fondoCaja = fondoInput.toDoubleOrNull() ?: 0.0
                    ShiftManager.isShiftOpen = true
                    ShiftManager.openTimestamp = System.currentTimeMillis()
                    ShiftManager.currentCashier = GoogleSignInState.nombre
                    showOpeningDialog = false
                }) { Text("ACEPTAR") }
            },
            dismissButton = { TextButton(onClick = { showOpeningDialog = false }) { Text("CANCELAR") } }
        )
    }

    if (showNewSalePopup) {
        NewSaleDialog(
            onDismiss = { showNewSalePopup = false },
            onConfirm = { sale -> 
                try {
                    ShiftManager.sales.add(0, sale)
                    transactionSuccessMessage = "Se cobraron $${sale.amount} con éxito"
                    showNewSalePopup = false
                } catch (e: Exception) {
                    transactionErrorMessage = "Fallo el cobro"
                }
            }
        )
    }

    if (showExpensePopup) {
        ExpenseDialog(
            onDismiss = { showExpensePopup = false },
            onConfirm = { expense ->
                ShiftManager.expenses.add(expense)
                showExpensePopup = false
                Toast.makeText(context, "Gasto registrado", Toast.LENGTH_SHORT).show()
            }
        )
    }

    if (showCortePopup) {
        CorteDialog(
            sales = ShiftManager.sales,
            expenses = ShiftManager.expenses,
            onDismiss = { showCortePopup = false },
            onConfirm = { 
                ShiftManager.isShiftOpen = false
                ShiftManager.sales.clear()
                ShiftManager.expenses.clear()
                showCortePopup = false
                navController.popBackStack()
            }
        )
    }
}

@Composable
fun SaleRow(sale: POSSale, isSelected: Boolean, onClick: () -> Unit) {
    val statusColor = if(sale.status == "Cancelada") Color.Red else (if(sale.method == "Efectivo") SuccessGreen else ActionBlue)
    Row(
        modifier = Modifier.fillMaxWidth().background(if(isSelected) ActionBlue.copy(alpha = 0.1f) else Color.Transparent).clickable { onClick() }.padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(statusColor))
        Spacer(Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text("Venta #${sale.id.take(4)}", fontWeight = FontWeight.Bold)
            Text(sale.method, fontSize = 12.sp, color = Color.Gray)
        }
        Text("$${sale.amount}", fontWeight = FontWeight.Black, color = if(sale.status == "Cancelada") Color.Red else PrimaryNavy)
    }
}

@Composable
fun ActionButton(icon: ImageVector, label: String, color: Color, onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(modifier = Modifier.size(56.dp).clip(RoundedCornerShape(16.dp)).background(color.copy(alpha = 0.1f)).clickable { onClick() }, contentAlignment = Alignment.Center) {
            Icon(icon, null, tint = color)
        }
        Text(label, style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold, color = color)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewSaleDialog(onDismiss: () -> Unit, onConfirm: (POSSale) -> Unit) {
    var step by remember { mutableStateOf(1) } // 1: Resumen Nota, 2: Productos (Pestañas), 4: Cantidad, 5: Cobro
    val saleDetails = remember { mutableStateListOf<POSItem>() }
    var selectedCategory by remember { mutableStateOf("Comidas") }
    var selectedProduct by remember { mutableStateOf<POSItem?>(null) }
    var qtyInput by remember { mutableStateOf("") }
    var paymentMethod by remember { mutableStateOf("Efectivo") }
    var amountPaid by remember { mutableStateOf("") }
    
    var showTempProductPopup by remember { mutableStateOf(false) }

    val products = listOf(
        POSItem("Taco Pastor", 15.0, "Comidas"),
        POSItem("Taco Bistec", 18.0, "Comidas"),
        POSItem("Coca 600ml", 20.0, "Bebidas"),
        POSItem("Fanta 600ml", 20.0, "Bebidas"),
        POSItem("Flan", 35.0, "Postres")
    )

    AlertDialog(
        onDismissRequest = onDismiss,
        properties = androidx.compose.ui.window.DialogProperties(usePlatformDefaultWidth = false),
        modifier = Modifier.fillMaxSize().padding(16.dp),
        content = {
            Surface(modifier = Modifier.fillMaxSize(), shape = RoundedCornerShape(28.dp), color = Color.White) {
                Column(modifier = Modifier.padding(24.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        if(step > 1) IconButton(onClick = { step = if(step == 5) 1 else if(step == 4) 2 else 1 }) { Icon(Icons.Default.ArrowBack, null) }
                        Text(
                            text = when(step) {
                                1 -> "Nota de Venta"
                                2 -> "Productos"
                                4 -> "Cantidad"
                                else -> "Resumen de venta"
                            }, 
                            style = MaterialTheme.typography.titleLarge, 
                            fontWeight = FontWeight.Black
                        )
                        Spacer(Modifier.weight(1f))
                        IconButton(onClick = onDismiss) { Icon(Icons.Default.Close, null) }
                    }
                    
                    Box(modifier = Modifier.weight(1f).padding(vertical = 16.dp)) {
                        when(step) {
                            1 -> {
                                Column {
                                    Box(modifier = Modifier.weight(1f)) {
                                        if(saleDetails.isEmpty()) {
                                            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { Text("Sin productos seleccionados", color = Color.Gray) }
                                        } else {
                                            LazyColumn { items(saleDetails) { item -> Row(modifier = Modifier.fillMaxWidth().padding(8.dp)) { Text("${item.quantity}x ${item.name}", modifier = Modifier.weight(1f)); Text("$${item.price * item.quantity}") } } }
                                        }
                                    }
                                    
                                    // AGREGAR PRODUCTO DEBAJO DE LA LISTA (Solicitado)
                                    TextButton(onClick = { step = 2 }, modifier = Modifier.fillMaxWidth()) {
                                        Text("+ AGREGAR PRODUCTO", color = ActionBlue, fontWeight = FontWeight.Bold)
                                    }
                                    
                                    if(saleDetails.isNotEmpty()) {
                                        Button(onClick = { step = 5 }, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(20.dp)) {
                                            Text("COBRAR", fontWeight = FontWeight.Black)
                                        }
                                    }
                                }
                            }
                            2 -> {
                                // PESTAÑAS DE CATEGORIA (Tipo Navegador solicitado)
                                Column {
                                    Row(modifier = Modifier.fillMaxWidth().background(Color.LightGray.copy(alpha = 0.1f), RoundedCornerShape(12.dp))) {
                                        listOf("Comidas", "Bebidas", "Postres").forEach { cat ->
                                            Box(
                                                modifier = Modifier.weight(1f).height(45.dp).clip(RoundedCornerShape(12.dp))
                                                    .background(if(selectedCategory == cat) ActionBlue else Color.Transparent)
                                                    .clickable { selectedCategory = cat },
                                                contentAlignment = Alignment.Center
                                            ) {
                                                Text(cat, color = if(selectedCategory == cat) Color.White else Color.Gray, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                            }
                                        }
                                    }
                                    Spacer(Modifier.height(16.dp))
                                    LazyColumn(modifier = Modifier.weight(1f)) {
                                        items(products.filter { it.category == selectedCategory }) { prod ->
                                            Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp).clickable { selectedProduct = prod; step = 4 }, shape = RoundedCornerShape(12.dp)) {
                                                Row(modifier = Modifier.padding(16.dp)) { Text(prod.name, fontWeight = FontWeight.Bold); Spacer(Modifier.weight(1f)); Text("$${prod.price}") }
                                            }
                                        }
                                        // AGREGAR PRODUCTO NUEVO AL FINAL DE LA LISTA (Solicitado)
                                        item {
                                            Card(
                                                modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp).clickable { showTempProductPopup = true },
                                                colors = CardDefaults.cardColors(containerColor = ActionBlue.copy(alpha = 0.05f)),
                                                border = androidx.compose.foundation.BorderStroke(1.dp, ActionBlue.copy(alpha = 0.2f))
                                            ) {
                                                Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                                                    Icon(Icons.Default.Add, null, tint = ActionBlue)
                                                    Spacer(Modifier.width(8.dp))
                                                    Text("Agregar producto nuevo", color = ActionBlue, fontWeight = FontWeight.Bold)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            4 -> {
                                Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.fillMaxWidth()) {
                                    Text(selectedProduct?.name ?: "", fontWeight = FontWeight.Black, fontSize = 28.sp)
                                    Spacer(Modifier.height(24.dp))
                                    OutlinedTextField(
                                        value = qtyInput, 
                                        onValueChange = { if(it.all { c -> c.isDigit() }) qtyInput = it }, 
                                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), 
                                        label = { Text("Cantidad") },
                                        textStyle = LocalTextStyle.current.copy(textAlign = TextAlign.Center, fontSize = 24.sp),
                                        modifier = Modifier.fillMaxWidth(0.7f)
                                    )
                                    Spacer(Modifier.height(32.dp))
                                    Button(onClick = { selectedProduct?.let { p -> val q = qtyInput.toIntOrNull() ?: 1; saleDetails.add(p.copy(quantity = q)); step = 1; qtyInput = "" } }, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(20.dp)) { Text("ACEPTAR") }
                                }
                            }
                            5 -> {
                                val total = saleDetails.sumOf { it.price * it.quantity }
                                Column {
                                    // RESUMEN TIPO TICKET (Solicitado)
                                    Surface(color = Color.LightGray.copy(alpha = 0.05f), shape = RoundedCornerShape(12.dp), modifier = Modifier.fillMaxWidth().padding(bottom = 16.dp)) {
                                        Column(modifier = Modifier.padding(12.dp)) {
                                            saleDetails.forEach { item ->
                                                Row(modifier = Modifier.fillMaxWidth()) {
                                                    Text("${item.quantity} ${item.name}", modifier = Modifier.weight(1f), fontSize = 14.sp)
                                                    Text("$${item.price * item.quantity}", fontSize = 14.sp, fontWeight = FontWeight.Bold)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Text("TOTAL: $${total}", fontSize = 32.sp, fontWeight = FontWeight.Black, color = PrimaryNavy)
                                    Spacer(Modifier.height(16.dp))
                                    Row {
                                        Button(onClick = { paymentMethod = "Efectivo" }, modifier = Modifier.weight(1f).height(50.dp), shape = RoundedCornerShape(12.dp), colors = ButtonDefaults.buttonColors(containerColor = if(paymentMethod == "Efectivo") ActionBlue else Color.Gray)) { Text("Efectivo") }
                                        Spacer(Modifier.width(8.dp))
                                        Button(onClick = { paymentMethod = "Tarjeta" }, modifier = Modifier.weight(1f).height(50.dp), shape = RoundedCornerShape(12.dp), colors = ButtonDefaults.buttonColors(containerColor = if(paymentMethod == "Tarjeta") ActionBlue else Color.Gray)) { Text("Tarjeta") }
                                    }
                                    
                                    if(paymentMethod == "Efectivo") {
                                        Spacer(Modifier.height(16.dp))
                                        OutlinedTextField(
                                            value = amountPaid, 
                                            onValueChange = { if(it.all { c -> c.isDigit() }) amountPaid = it }, 
                                            label = { Text("Paga con") },
                                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                            modifier = Modifier.fillMaxWidth()
                                        )
                                        val p = amountPaid.toDoubleOrNull() ?: 0.0
                                        if(p >= total) {
                                            // CALCULO DE VUELTO INMEDIATO LETRAS GRANDES (Solicitado)
                                            Column(modifier = Modifier.padding(top = 12.dp)) {
                                                Text("CAMBIO", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = SuccessGreen)
                                                Text("$${p - total}", color = SuccessGreen, fontSize = 40.sp, fontWeight = FontWeight.Black)
                                            }
                                        }
                                    }
                                    
                                    Spacer(Modifier.height(24.dp))
                                    Button(
                                        onClick = { 
                                            val summaries = saleDetails.map { SaleItemSummary(it.name, it.quantity, it.price * it.quantity) }
                                            onConfirm(POSSale(UUID.randomUUID().toString(), total, paymentMethod, "Cobrada", items = summaries)) 
                                        }, 
                                        modifier = Modifier.fillMaxWidth().height(60.dp),
                                        shape = RoundedCornerShape(20.dp),
                                        colors = ButtonDefaults.buttonColors(containerColor = SuccessGreen)
                                    ) { Text("COBRA", fontWeight = FontWeight.Black, fontSize = 18.sp) }
                                }
                            }
                        }
                    }
                }
            }
        }
    )
    
    if (showTempProductPopup) {
        AlertDialog(
            onDismissRequest = { showTempProductPopup = false },
            title = { Text("Nuevo Producto") },
            text = { Text("Módulo de registro en desarrollo...") },
            confirmButton = { Button(onClick = { showTempProductPopup = false }) { Text("ACEPTAR") } },
            dismissButton = { TextButton(onClick = { showTempProductPopup = false }) { Text("ATRÁS") } }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExpenseDialog(onDismiss: () -> Unit, onConfirm: (POSExpense) -> Unit) {
    var detalle by remember { mutableStateOf("") }
    var cantidad by remember { mutableStateOf("") }
    
    AlertDialog(
        onDismissRequest = onDismiss,
        content = {
            Surface(shape = RoundedCornerShape(24.dp), color = Color.White) {
                Column(modifier = Modifier.padding(24.dp)) {
                    Text("Registrar Gasto", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Black)
                    Spacer(Modifier.height(16.dp))
                    OutlinedTextField(value = detalle, onValueChange = { detalle = it }, label = { Text("Detalle (ej: Servilletas)") }, modifier = Modifier.fillMaxWidth())
                    Spacer(Modifier.height(12.dp))
                    OutlinedTextField(value = cantidad, onValueChange = { if(it.all { c -> c.isDigit() }) cantidad = it }, label = { Text("Total") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), modifier = Modifier.fillMaxWidth())
                    
                    Spacer(Modifier.height(16.dp))
                    Button(onClick = { /* Camara */ }, modifier = Modifier.fillMaxWidth(), colors = ButtonDefaults.buttonColors(containerColor = Color.LightGray)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Place, null) // Placeholder camara
                            Spacer(Modifier.width(8.dp))
                            Text("TOMAR FOTO TICKET")
                        }
                    }
                    
                    Spacer(Modifier.height(24.dp))
                    Button(onClick = { onConfirm(POSExpense(detail = detalle, amount = cantidad.toDoubleOrNull() ?: 0.0, cashier = GoogleSignInState.nombre)) }, modifier = Modifier.fillMaxWidth().height(50.dp)) {
                        Text("REGISTRAR GASTO")
                    }
                    TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) { Text("CANCELAR") }
                }
            }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CorteDialog(sales: List<POSSale>, expenses: List<POSExpense>, onDismiss: () -> Unit, onConfirm: () -> Unit) {
    val totalSales = sales.filter { it.status == "Cobrada" }.sumOf { it.amount }
    val totalCash = sales.filter { it.status == "Cobrada" && it.method == "Efectivo" }.sumOf { it.amount }
    val totalCard = sales.filter { it.status == "Cobrada" && it.method == "Tarjeta" }.sumOf { it.amount }
    val totalExp = expenses.sumOf { it.amount }
    val cashInDrawer = totalCash + ShiftManager.fondoCaja - totalExp
    val canceledCount = sales.count { it.status == "Cancelada" }

    AlertDialog(
        onDismissRequest = onDismiss,
        content = {
            Surface(shape = RoundedCornerShape(28.dp), color = Color.White) {
                Column(modifier = Modifier.padding(24.dp)) {
                    Text("¿Cerrar Corte?", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Black)
                    Spacer(Modifier.height(16.dp))
                    
                    Text("Responsable: ${ShiftManager.currentCashier}", fontWeight = FontWeight.Bold)
                    Divider(modifier = Modifier.padding(vertical = 8.dp))
                    
                    ReportRow("Total Ventas:", "$$totalSales")
                    ReportRow("Pago con Tarjeta:", "$$totalCard")
                    ReportRow("Pago en Efectivo:", "$$totalCash")
                    ReportRow("Total Gastos:", "$$totalExp")
                    
                    Divider(modifier = Modifier.padding(vertical = 8.dp))
                    
                    ReportRow("Fondo Inicial:", "$${ShiftManager.fondoCaja}")
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("EFECTIVO EN CAJA:", fontWeight = FontWeight.Black)
                        Text("$${cashInDrawer}", fontWeight = FontWeight.Black, color = SuccessGreen)
                    }
                    
                    Spacer(Modifier.height(12.dp))
                    Text("Ventas Canceladas: $canceledCount", color = Color.Gray, fontSize = 12.sp)

                    if(ShiftManager.fondoCaja == 0.0) {
                        Text("AVISO: Corte realizado sin fondo de caja", color = Color.Red, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                    
                    Spacer(Modifier.height(24.dp))
                    
                    Button(onClick = onConfirm, modifier = Modifier.fillMaxWidth().height(60.dp), colors = ButtonDefaults.buttonColors(containerColor = Color.Red), shape = RoundedCornerShape(20.dp)) { 
                        Text("HACER CORTE", fontWeight = FontWeight.Black) 
                    }
                    TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) { 
                        Text("REGRESAR", color = Color.Gray) 
                    }
                }
            }
        }
    )
}

@Composable
fun ReportRow(label: String, value: String) {
    Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(label, color = Color.Gray)
        Text(value, fontWeight = FontWeight.Bold)
    }
}
