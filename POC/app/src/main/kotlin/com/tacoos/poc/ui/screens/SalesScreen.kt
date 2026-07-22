package com.tacoos.poc.ui.screens

import android.graphics.Bitmap
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.result.launch
import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
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
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.TacoRepository
import com.tacoos.poc.data.local.*
import com.tacoos.poc.ui.components.ActionButton
import com.tacoos.poc.ui.components.AppleToggle
import com.tacoos.poc.ui.components.ReportRow
import com.tacoos.poc.ui.components.TacoDialog
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import com.tacoos.poc.ui.theme.SuccessGreen
import com.tacoos.poc.ui.theme.WarningAmber
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

/**
 * SalesScreen: Pantalla principal del Punto de Venta (POS).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SalesScreen(
    navController: NavController,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit
) {
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    val app = context.applicationContext as TacoApp
    val repository = TacoRepository(app.api, app.database)
    
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    var selectedNote by remember { mutableStateOf<SaleNote?>(null) }

    // Controladores de visibilidad
    var showOpeningDialog by remember { mutableStateOf(false) }
    var showNewSalePopup by remember { mutableStateOf(false) }
    var showCortePopup by remember { mutableStateOf(false) }
    var showExpensePopup by remember { mutableStateOf(false) }

    var transactionSuccessMessage by remember { mutableStateOf<String?>(null) }
    var transactionErrorMessage by remember { mutableStateOf<String?>(null) }

    val dateFormat = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault())

    // Sincronización inicial
    LaunchedEffect(Unit) {
        val currentUser = repository.getCurrentUser()
        if (currentUser != null) {
            val active = repository.getActiveShift(currentUser.negocioId ?: "")
            if (active != null) {
                ShiftManager.isShiftOpen = true
                ShiftManager.activeShiftId = active.id
                ShiftManager.openTimestamp = active.openTimestamp
                ShiftManager.fondoCaja = active.initialCash
                ShiftManager.currentCashier = currentUser.nombre
                
                ShiftManager.sales.clear()
                ShiftManager.sales.addAll(repository.getNotesByShift(active.id))
                ShiftManager.expenses.clear()
                ShiftManager.expenses.addAll(repository.getExpensesByShift(active.id))
            }
        }
    }

    LaunchedEffect(transactionSuccessMessage) {
        if (transactionSuccessMessage != null) {
            delay(1500)
            transactionSuccessMessage = null
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
                    Row(modifier = Modifier.fillMaxWidth().background(Color.LightGray.copy(alpha = 0.1f)).padding(12.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date()), fontWeight = FontWeight.Bold, color = Color.Gray)
                        Text(ShiftManager.currentCashier, fontWeight = FontWeight.Bold, color = ActionBlue)
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
                                Text("SESIÓN ACTIVA", style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold)
                                Spacer(Modifier.width(8.dp))
                                Box(modifier = Modifier.size(8.dp).clip(CircleShape).background(SuccessGreen))
                            }
                            Text("Abierta: ${dateFormat.format(Date(ShiftManager.openTimestamp))}", fontSize = 10.sp, color = Color.Gray)
                            Spacer(Modifier.height(16.dp))
                            Surface(modifier = Modifier.weight(1f).fillMaxWidth(), shape = RoundedCornerShape(24.dp), color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f), border = androidx.compose.foundation.BorderStroke(1.dp, Color.LightGray.copy(alpha = 0.3f))) {
                                if (ShiftManager.sales.isEmpty()) {
                                    Box(contentAlignment = Alignment.Center) { Text("Sin ventas", color = Color.Gray) }
                                } else {
                                    LazyColumn {
                                        items(ShiftManager.sales, key = { it.id }) { note ->
                                            SaleRow(note, isSelected = selectedNote?.id == note.id) {
                                                selectedNote = note
                                            }
                                        }
                                    }
                                }
                            }
                            Row(modifier = Modifier.fillMaxWidth().padding(vertical = 16.dp), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.CenterVertically) {
                                ActionButton(Icons.Default.Close, "Anular", Color.Red) {
                                    selectedNote?.let { note ->
                                        if (System.currentTimeMillis() - note.timestamp < 300000) {
                                            scope.launch {
                                                repository.updateNote(note.copy(isCancelled = true))
                                                selectedNote = null
                                            }
                                        } else {
                                            Toast.makeText(context, "Registro inmutable (> 5 min)", Toast.LENGTH_SHORT).show()
                                        }
                                    }
                                }
                                ActionButton(Icons.Default.ShoppingCart, "Gasto", WarningAmber) { showExpensePopup = true }
                                ActionButton(Icons.Default.Add, "Venta", SuccessGreen) { showNewSalePopup = true }
                            }
                            Button(onClick = { showCortePopup = true }, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(16.dp), colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy)) {
                                Text("CERRAR CORTE", fontWeight = FontWeight.Black)
                            }
                        }
                    }
                }
                if (transactionSuccessMessage != null) TransactionBanner(transactionSuccessMessage!!, SuccessGreen)
                if (transactionErrorMessage != null) TransactionBanner(transactionErrorMessage!!, Color.Red)
            }
        }
    }

    if (showOpeningDialog) {
        OpeningForm(onDismiss = { showOpeningDialog = false }) { fondo ->
            scope.launch {
                val user = repository.getCurrentUser()
                if (user != null) {
                    repository.openShift(user.negocioId ?: "", user.id, user.tenantId, fondo)
                    val active = repository.getActiveShift(user.negocioId ?: "")
                    if(active != null) {
                        ShiftManager.isShiftOpen = true
                        ShiftManager.activeShiftId = active.id
                        ShiftManager.fondoCaja = fondo
                        ShiftManager.openTimestamp = active.openTimestamp
                        ShiftManager.currentCashier = user.nombre
                    }
                }
                showOpeningDialog = false
            }
        }
    }

    if (showNewSalePopup) {
        NewSaleDialog(
            onDismiss = { showNewSalePopup = false },
            onConfirm = { note, details ->
                scope.launch {
                    try {
                        repository.saveSaleWithDetails(note, details)
                        ShiftManager.sales.add(0, note)
                        transactionSuccessMessage = "Cobro exitoso: $${note.totalAmount}"
                        showNewSalePopup = false
                    } catch (e: Exception) {
                        transactionErrorMessage = "Fallo el cobro"
                    }
                }
            }
        )
    }

    if (showExpensePopup) {
        ExpenseDialog(onDismiss = { showExpensePopup = false }) { expense ->
            scope.launch {
                repository.saveExpense(expense)
                ShiftManager.expenses.add(expense)
                showExpensePopup = false
            }
        }
    }

    if (showCortePopup) {
        CorteDialog(
            sales = ShiftManager.sales,
            expenses = ShiftManager.expenses,
            onDismiss = { showCortePopup = false },
            onConfirm = {
                scope.launch {
                    ShiftManager.activeShiftId?.let { _ ->
                        // Lógica de cierre de corte
                        ShiftManager.isShiftOpen = false
                        ShiftManager.sales.clear()
                        ShiftManager.expenses.clear()
                        showCortePopup = false
                        navController.popBackStack()
                    }
                }
            }
        )
    }
}

@Composable
fun TransactionBanner(message: String, color: Color) {
    Box(modifier = Modifier.fillMaxWidth().height(50.dp).background(color), contentAlignment = Alignment.Center) {
        Text(message, color = Color.White, fontWeight = FontWeight.Bold)
    }
}

@Composable
fun OpeningForm(onDismiss: () -> Unit, onConfirm: (Double) -> Unit) {
    var fondoInput by remember { mutableStateOf("") }
    TacoDialog(title = "Abrir Caja", onDismiss = onDismiss, confirmButton = { Button(onClick = { onConfirm(fondoInput.toDoubleOrNull() ?: 0.0) }) { Text("ACEPTAR") } }, dismissButton = { TextButton(onClick = onDismiss) { Text("CANCELAR") } }) {
        Text("¿Deseas ingresar un fondo de caja?")
        Spacer(Modifier.height(16.dp))
        OutlinedTextField(value = fondoInput, onValueChange = { if (it.all { c -> c.isDigit() }) fondoInput = it }, label = { Text("Cantidad") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), modifier = Modifier.fillMaxWidth())
    }
}

@Composable
fun SaleRow(note: SaleNote, isSelected: Boolean, onClick: () -> Unit) {
    val statusColor = if (note.isSynced) SuccessGreen else ActionBlue
    Row(modifier = Modifier.fillMaxWidth().background(if (isSelected) ActionBlue.copy(alpha = 0.1f) else Color.Transparent).clickable { onClick() }.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(statusColor))
        Spacer(Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text("Venta #${note.id.take(4)}", fontWeight = FontWeight.Bold)
            Text(note.paymentMethod, fontSize = 12.sp, color = Color.Gray)
        }
        Text("$${note.totalAmount}", fontWeight = FontWeight.Black, color = PrimaryNavy)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewSaleDialog(onDismiss: () -> Unit, onConfirm: (SaleNote, List<SaleDetail>) -> Unit) {
    val scope = rememberCoroutineScope()
    var step by remember { mutableStateOf(1) }
    val saleItems = remember { mutableStateListOf<POSItem>() }
    val sessionItems = remember { mutableStateListOf<POSItem>() }
    var selectedCategory by remember { mutableStateOf("Comidas") }
    var showCobroPopup by remember { mutableStateOf(false) }
    var itemToDeleteIndex by remember { mutableStateOf<Int?>(null) }
    val context = LocalContext.current
    val app = context.applicationContext as TacoApp
    val repository = TacoRepository(app.api, app.database)

    val products = listOf(
        POSItem("Taco Pastor", 15.0, "Comidas"),
        POSItem("Taco Bistec", 18.0, "Comidas"),
        POSItem("Coca 600ml", 20.0, "Bebidas"),
        POSItem("Fanta 600ml", 20.0, "Bebidas"),
        POSItem("Flan", 35.0, "Postres")
    )

    TacoDialog(title = if (step == 1) "Nota de Venta" else "Agregar Producto", onDismiss = onDismiss, maxHeightFactor = 0.6f, navigationIcon = if (step > 1) Icons.Default.ArrowBack else null, onNavigationClick = { step = 1 }) {
        if (step == 1) {
            Column {
                Box(modifier = Modifier.weight(1f)) {
                    if (saleItems.isEmpty()) { Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { Text("Sin productos", color = Color.Gray) } }
                    else {
                        Box {
                            LazyColumn {
                                itemsIndexed(saleItems) { index, item ->
                                    Row(modifier = Modifier.fillMaxWidth().clickable { itemToDeleteIndex = index }.padding(8.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                                        Text("${item.quantity}x ${item.name}", modifier = Modifier.weight(1f)); Text("$${item.price * item.quantity}")
                                    }
                                }
                            }
                            if (itemToDeleteIndex != null) {
                                Box(modifier = Modifier.fillMaxSize().clickable { itemToDeleteIndex = null }, contentAlignment = Alignment.Center) {
                                    Surface(shape = RoundedCornerShape(16.dp), color = Color.White, shadowElevation = 8.dp) {
                                        IconButton(onClick = { saleItems.removeAt(itemToDeleteIndex!!); itemToDeleteIndex = null }) { Icon(Icons.Default.Delete, null, tint = Color.Red) }
                                    }
                                }
                            }
                        }
                    }
                }
                TextButton(onClick = { step = 2 }, modifier = Modifier.fillMaxWidth()) { Text("+ AGREGAR PRODUCTO", color = ActionBlue, fontWeight = FontWeight.Bold) }
                if (saleItems.isNotEmpty()) { Button(onClick = { showCobroPopup = true }, modifier = Modifier.fillMaxWidth().height(50.dp), shape = RoundedCornerShape(16.dp)) { Text("COBRAR", fontWeight = FontWeight.Black) } }
            }
        } else {
            Column {
                Row(modifier = Modifier.fillMaxWidth().background(Color.LightGray.copy(alpha = 0.1f), RoundedCornerShape(12.dp))) {
                    listOf("Comidas", "Bebidas", "Postres").forEach { cat ->
                        Box(modifier = Modifier.weight(1f).height(40.dp).clip(RoundedCornerShape(12.dp)).background(if (selectedCategory == cat) ActionBlue else Color.Transparent).clickable { selectedCategory = cat }, contentAlignment = Alignment.Center) { Text(cat, color = if (selectedCategory == cat) Color.White else Color.Gray, fontWeight = FontWeight.Bold, fontSize = 11.sp) }
                    }
                }
                Spacer(Modifier.height(8.dp))
                LazyColumn(modifier = Modifier.weight(1f)) {
                    items(products.filter { it.category == selectedCategory }) { prod -> ProductRowInline(prod) { qty -> sessionItems.add(prod.copy(quantity = qty)) } }
                    if (sessionItems.isNotEmpty()) {
                        item { Divider(Modifier.padding(vertical = 12.dp)) }
                        items(sessionItems) { item -> Row(modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp)) { Text("${item.quantity} ${item.name}", fontSize = 11.sp, color = Color.Gray, modifier = Modifier.weight(1f)); Text("$${item.price * item.quantity}", fontSize = 11.sp, color = Color.Gray) } }
                        item { Button(onClick = { 
                            sessionItems.forEach { si -> 
                                val existing = saleItems.find { it.name == si.name }
                                if(existing != null) existing.quantity += si.quantity else saleItems.add(si.copy())
                            }
                            sessionItems.clear()
                            step = 1 
                        }, modifier = Modifier.fillMaxWidth().padding(top = 16.dp), colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy)) { Text("Listo", fontWeight = FontWeight.Bold) } }
                    }
                }
            }
        }
    }

    if (showCobroPopup) {
        val total = saleItems.sumOf { it.price * it.quantity }
        CobroForm(items = saleItems, onDismiss = { showCobroPopup = false }) { paymentMethod ->
            scope.launch {
                val user = repository.getCurrentUser()
                if (user != null && ShiftManager.activeShiftId != null) {
                    val noteId = UUID.randomUUID().toString()
                    val note = SaleNote(
                        id = noteId,
                        shiftId = ShiftManager.activeShiftId!!,
                        businessId = user.negocioId ?: "",
                        cashierId = user.id,
                        tenantId = user.tenantId,
                        totalAmount = total,
                        paymentMethod = paymentMethod
                    )
                    val details = saleItems.map { 
                        SaleDetail(
                            noteId = noteId,
                            productName = it.name,
                            quantity = it.quantity,
                            unitPrice = it.price,
                            subtotal = it.price * it.quantity
                        )
                    }
                    onConfirm(note, details)
                }
            }
            showCobroPopup = false
        }
    }
}

@Composable
fun CobroForm(items: List<POSItem>, onDismiss: () -> Unit, onConfirm: (String) -> Unit) {
    val total = items.sumOf { it.price * it.quantity }
    var paymentMethod by remember { mutableStateOf("Efectivo") }
    var amountPaidInput by remember { mutableStateOf("") }
    TacoDialog(title = "Resumen de venta", onDismiss = onDismiss, maxHeightFactor = 0.6f) {
        LazyColumn(modifier = Modifier.weight(1f)) {
            items(items) { item -> Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceBetween) { Text("${item.quantity} ${item.name}", color = Color.Gray); Text("$${item.price * item.quantity}", fontWeight = FontWeight.Bold) } }
        }
        Divider(Modifier.padding(vertical = 8.dp))
        ReportRow("TOTAL:", "$${total}", isBold = true, color = PrimaryNavy)
        Row(modifier = Modifier.fillMaxWidth()) {
            Button(onClick = { paymentMethod = "Efectivo" }, modifier = Modifier.weight(1f), colors = ButtonDefaults.buttonColors(containerColor = if (paymentMethod == "Efectivo") ActionBlue else Color.Gray)) { Text("Efectivo") }
            Spacer(Modifier.width(8.dp))
            Button(onClick = { paymentMethod = "Tarjeta" }, modifier = Modifier.weight(1f), colors = ButtonDefaults.buttonColors(containerColor = if (paymentMethod == "Tarjeta") ActionBlue else Color.Gray)) { Text("Tarjeta") }
        }
        if (paymentMethod == "Efectivo") {
            OutlinedTextField(value = amountPaidInput, onValueChange = { if (it.all { c -> c.isDigit() }) amountPaidInput = it }, label = { Text("Paga con") }, modifier = Modifier.fillMaxWidth())
            val p = amountPaidInput.toDoubleOrNull() ?: 0.0
            if (p >= total) {
                val change = p - total
                Column(modifier = Modifier.padding(top = 12.dp)) {
                    Text("CAMBIO", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = SuccessGreen)
                    Text("$${change}", color = SuccessGreen, fontSize = 36.sp, fontWeight = FontWeight.Black)
                }
            }
        }
        Button(onClick = { onConfirm(paymentMethod) }, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(20.dp), colors = ButtonDefaults.buttonColors(containerColor = SuccessGreen)) { Text("COBRA", fontWeight = FontWeight.Black, fontSize = 18.sp) }
    }
}

@Composable
fun ProductRowInline(prod: POSItem, onAdd: (Int) -> Unit) {
    var qty by remember { mutableStateOf("") }
    val focusRequester = remember { FocusRequester() }
    var isSelected by remember { mutableStateOf(false) }
    Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp).clickable { isSelected = true }, shape = RoundedCornerShape(12.dp), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)) {
        Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(modifier = Modifier.size(40.dp).clip(RoundedCornerShape(8.dp)).background(Color.LightGray.copy(alpha = 0.2f)))
            Spacer(Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) { Text(prod.name, fontWeight = FontWeight.Bold); Text("$${prod.price}", color = ActionBlue, fontSize = 12.sp) }
            if (isSelected) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    OutlinedTextField(value = qty, onValueChange = { if (it.all { c -> c.isDigit() }) qty = it }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), modifier = Modifier.width(70.dp).focusRequester(focusRequester), textStyle = LocalTextStyle.current.copy(textAlign = TextAlign.Center))
                    IconButton(onClick = { if (qty.isNotEmpty()) { onAdd(qty.toInt()); qty = "" } }) { Icon(Icons.Default.Add, null, tint = ActionBlue) }
                    LaunchedEffect(Unit) { focusRequester.requestFocus() }
                }
            } else { Icon(Icons.Default.KeyboardArrowRight, null, tint = Color.LightGray) }
        }
    }
}

@Composable
fun ExpenseDialog(onDismiss: () -> Unit, onConfirm: (Expense) -> Unit) {
    val scope = rememberCoroutineScope()
    var detalle by remember { mutableStateOf("") }
    var cantidad by remember { mutableStateOf("") }
    var capturedPhoto by remember { mutableStateOf<Bitmap?>(null) }
    val cameraLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicturePreview()) { capturedPhoto = it }
    val context = LocalContext.current
    val app = context.applicationContext as TacoApp
    val repository = TacoRepository(app.api, app.database)

    TacoDialog(title = "Registrar Gasto", onDismiss = onDismiss, maxHeightFactor = 0.6f) {
        OutlinedTextField(value = detalle, onValueChange = { detalle = it }, label = { Text("Detalle") }, modifier = Modifier.fillMaxWidth())
        OutlinedTextField(value = cantidad, onValueChange = { if (it.all { c -> c.isDigit() }) cantidad = it }, label = { Text("Total") }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(8.dp))
        Button(onClick = { cameraLauncher.launch() }, modifier = Modifier.fillMaxWidth(), colors = ButtonDefaults.buttonColors(containerColor = Color.LightGray)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.AddCircle, null); Spacer(Modifier.width(8.dp)); Text(if (capturedPhoto != null) "FOTO CAPTURADA" else "TOMAR FOTO TICKET")
            }
        }
        Button(onClick = { 
            scope.launch {
                val user = repository.getCurrentUser()
                if(user != null && ShiftManager.activeShiftId != null) {
                    onConfirm(Expense(
                        shiftId = ShiftManager.activeShiftId!!,
                        cashierId = user.id,
                        businessId = user.negocioId ?: "",
                        tenantId = user.tenantId,
                        description = detalle,
                        amount = cantidad.toDoubleOrNull() ?: 0.0
                    )) 
                }
            }
        }, modifier = Modifier.fillMaxWidth()) { Text("REGISTRAR GASTO") }
        TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) { Text("CANCELAR") }
    }
}

@Composable
fun CorteDialog(sales: List<SaleNote>, expenses: List<Expense>, onDismiss: () -> Unit, onConfirm: () -> Unit) {
    val totalSales = sales.sumOf { it.totalAmount }
    val totalCash = sales.filter { it.paymentMethod == "Efectivo" }.sumOf { it.totalAmount }
    val totalCard = sales.filter { it.paymentMethod == "Tarjeta" }.sumOf { it.totalAmount }
    val totalExp = expenses.sumOf { it.amount }
    val cashInDrawer = totalCash + ShiftManager.fondoCaja - totalExp

    TacoDialog(title = "¿Cerrar Corte?", onDismiss = onDismiss, maxHeightFactor = 0.6f) {
        Text("Responsable: ${ShiftManager.currentCashier}", fontWeight = FontWeight.Bold)
        Divider(modifier = Modifier.padding(vertical = 8.dp))
        ReportRow("Total Ventas:", "$$totalSales")
        ReportRow("Pago con Tarjeta:", "$$totalCard")
        ReportRow("Pago en Efectivo:", "$$totalCash")
        ReportRow("Total Gastos:", "$$totalExp")
        Divider(modifier = Modifier.padding(vertical = 8.dp))
        ReportRow("Fondo Inicial:", "$${ShiftManager.fondoCaja}")
        ReportRow("EFECTIVO EN CAJA:", "$${cashInDrawer}", color = SuccessGreen)
        if (ShiftManager.fondoCaja == 0.0) Text("AVISO: Corte sin fondo", color = Color.Red, fontSize = 12.sp, fontWeight = FontWeight.Bold)
        Button(onClick = onConfirm, modifier = Modifier.fillMaxWidth().height(60.dp), colors = ButtonDefaults.buttonColors(containerColor = Color.Red), shape = RoundedCornerShape(20.dp)) { Text("HACER CORTE", fontWeight = FontWeight.Black) }
        TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) { Text("REGRESAR", color = Color.Gray) }
    }
}
