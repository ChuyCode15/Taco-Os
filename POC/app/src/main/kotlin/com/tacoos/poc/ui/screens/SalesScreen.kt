package com.tacoos.poc.ui.screens

import android.media.RingtoneManager
import android.widget.Toast
import androidx.compose.animation.*
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
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

data class POSSale(
    val id: String,
    val amount: Double,
    val method: String, // "Efectivo", "Tarjeta"
    val status: String, // "Cobrada", "Cancelada"
    val timestamp: Long = System.currentTimeMillis()
)

data class POSItem(
    val name: String,
    val price: Double,
    val category: String, // "Comidas", "Bebidas", "Postres"
    var quantity: Int = 0
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SalesScreen(navController: NavController, isDarkMode: Boolean, onThemeChange: (Boolean) -> Unit) {
    val scope = rememberCoroutineScope()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val context = LocalContext.current
    
    var isShiftStarted by remember { mutableStateOf(false) }
    var sales = remember { mutableStateListOf<POSSale>() }
    var selectedSale by remember { mutableStateOf<POSSale?>(null) }
    
    // Nueva Venta State
    var showNewSalePopup by remember { mutableStateOf(false) }
    var cartItems = remember { mutableStateListOf<POSItem>() }
    
    // Corte State
    var showCortePopup by remember { mutableStateOf(false) }

    val dateFormat = SimpleDateFormat("dd/MM/yyyy", Locale.getDefault())
    val currentTime = dateFormat.format(Date())

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
                NavigationDrawerItem(label = { Text("Ajustes") }, selected = false, onClick = { navController.navigate("settings") }, icon = { Icon(Icons.Default.Settings, null) })
                Spacer(modifier = Modifier.weight(1f))
                Text("Cerrar Sesión", modifier = Modifier.padding(24.dp).clickable { navController.navigate("login") { popUpTo(0) { inclusive = true } } }, color = Color.Red, fontWeight = FontWeight.Black)
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
                    },
                    actions = {
                        IconButton(onClick = { /* Notif */ }) { Icon(Icons.Default.Notifications, null) }
                    }
                )
            }
        ) { padding ->
            Column(modifier = Modifier.fillMaxSize().padding(padding)) {
                // Barra de Info (Fecha y Usuario)
                Row(
                    modifier = Modifier.fillMaxWidth().background(Color.LightGray.copy(alpha = 0.1f)).padding(12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(currentTime, fontWeight = FontWeight.Bold, color = Color.Gray)
                    Text(GoogleSignInState.nombre.ifEmpty { "Usuario" }, fontWeight = FontWeight.Bold, color = ActionBlue)
                }

                if (!isShiftStarted) {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(Icons.Default.Lock, null, modifier = Modifier.size(80.dp), tint = Color.LightGray)
                            Spacer(Modifier.height(16.dp))
                            Text("CAJA CERRADA", fontWeight = FontWeight.Black, color = Color.Gray)
                            Spacer(Modifier.height(24.dp))
                            Button(onClick = { isShiftStarted = true }, shape = RoundedCornerShape(20.dp), colors = ButtonDefaults.buttonColors(containerColor = ActionBlue)) {
                                Text("ABRIR CAJA", fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                } else {
                    // Lista de Ventas POS Style
                    Column(modifier = Modifier.weight(1f).padding(16.dp)) {
                        Text("REGISTRO DE HOY", style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold)
                        Spacer(Modifier.height(8.dp))
                        
                        Surface(
                            modifier = Modifier.fillMaxSize().weight(1f),
                            shape = RoundedCornerShape(16.dp),
                            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
                            border = androidx.compose.foundation.BorderStroke(1.dp, Color.LightGray.copy(alpha = 0.5f))
                        ) {
                            LazyColumn {
                                items(sales) { sale ->
                                    SaleRow(sale, isSelected = selectedSale?.id == sale.id) { selectedSale = sale }
                                }
                            }
                        }

                        // Botones de Acción (Apple Style Horizontal)
                        Row(
                            modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
                            horizontalArrangement = Arrangement.SpaceEvenly
                        ) {
                            ActionButton(Icons.Default.Close, "Cancelar", Color.Red) {
                                selectedSale?.let { 
                                    if(System.currentTimeMillis() - it.timestamp < 300000) {
                                        sales[sales.indexOf(it)] = it.copy(status = "Cancelada")
                                        selectedSale = null
                                    } else {
                                        Toast.makeText(context, "Pasaron más de 5 min", Toast.LENGTH_SHORT).show()
                                    }
                                }
                            }
                            ActionButton(Icons.Default.Search, "Ver", ActionBlue) { /* Ver detalle */ }
                            ActionButton(Icons.Default.Add, "Venta", SuccessGreen) { showNewSalePopup = true }
                        }
                        
                        Spacer(Modifier.height(16.dp))
                        
                        Button(
                            onClick = { showCortePopup = true },
                            modifier = Modifier.align(Alignment.End),
                            colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy),
                            shape = RoundedCornerShape(12.dp)
                        ) {
                            Text("CERRAR CORTE")
                        }
                    }
                }
            }
        }
    }

    // POPUP NUEVA VENTA
    if (showNewSalePopup) {
        NewSaleDialog(
            onDismiss = { showNewSalePopup = false },
            onConfirm = { amount, method ->
                sales.add(0, POSSale(UUID.randomUUID().toString(), amount, method, "Cobrada"))
                showNewSalePopup = false
                cartItems.clear()
            }
        )
    }

    // POPUP CORTE
    if (showCortePopup) {
        CorteDialog(
            sales = sales,
            onDismiss = { showCortePopup = false },
            onConfirm = { 
                isShiftStarted = false
                sales.clear()
                showCortePopup = false
            }
        )
    }
}

@Composable
fun SaleRow(sale: POSSale, isSelected: Boolean, onClick: () -> Unit) {
    val statusColor = when(sale.status) {
        "Cancelada" -> Color.Red
        else -> if(sale.method == "Efectivo") SuccessGreen else Color(0xFF00BFFF)
    }
    
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(if(isSelected) ActionBlue.copy(alpha = 0.1f) else Color.Transparent)
            .clickable { onClick() }
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(statusColor))
        Spacer(Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text("Venta #${sale.id.take(4)}", fontWeight = FontWeight.Bold, fontSize = 14.sp)
            Text(sale.method, fontSize = 12.sp, color = Color.Gray)
        }
        Text("$${sale.amount}", fontWeight = FontWeight.Black, color = if(sale.status == "Cancelada") Color.Red else PrimaryNavy)
    }
}

@Composable
fun ActionButton(icon: ImageVector, label: String, color: Color, onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier.size(56.dp).clip(RoundedCornerShape(16.dp)).background(color.copy(alpha = 0.1f)).clickable { onClick() },
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, null, tint = color)
        }
        Text(label, style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold, color = color)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewSaleDialog(onDismiss: () -> Unit, onConfirm: (Double, String) -> Unit) {
    var step by remember { mutableStateOf(1) } // 1: Cart, 2: Categories, 3: Products, 4: Quantity, 5: Payment
    var cart = remember { mutableStateListOf<POSItem>() }
    var selectedCategory by remember { mutableStateOf("") }
    var selectedProduct by remember { mutableStateOf<POSItem?>(null) }
    var qtyInput by remember { mutableStateOf("") }
    var paymentMethod by remember { mutableStateOf("Efectivo") }

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
            Surface(modifier = Modifier.fillMaxSize(), shape = RoundedCornerShape(24.dp), color = Color.White) {
                Column(modifier = Modifier.padding(24.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        if(step > 1) IconButton(onClick = { step-- }) { Icon(Icons.Default.ArrowBack, null) }
                        Text(
                            text = when(step) {
                                1 -> "Nueva Venta"
                                2 -> "Categorías"
                                3 -> selectedCategory
                                4 -> "Cantidad"
                                else -> "Cobrar"
                            }, 
                            style = MaterialTheme.typography.headlineSmall, 
                            fontWeight = FontWeight.Black
                        )
                        Spacer(Modifier.weight(1f))
                        IconButton(onClick = onDismiss) { Icon(Icons.Default.Close, null) }
                    }
                    
                    Box(modifier = Modifier.weight(1f).padding(vertical = 16.dp)) {
                        when(step) {
                            1 -> {
                                if(cart.isEmpty()) {
                                    Box(modifier = Modifier.fillMaxSize().clickable { step = 2 }, contentAlignment = Alignment.Center) {
                                        Text("+ AGREGA PRODUCTO", fontWeight = FontWeight.Bold, color = ActionBlue)
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
                                        onValueChange = { if(it.length <= 9 && it.all { c -> c.isDigit() }) qtyInput = it },
                                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                        label = { Text("Cantidad") },
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    Spacer(Modifier.height(24.dp))
                                    Button(onClick = { 
                                        selectedProduct?.let { 
                                            it.quantity = qtyInput.toIntOrNull() ?: 1
                                            cart.add(it)
                                            step = 1
                                            qtyInput = ""
                                        }
                                    }, modifier = Modifier.fillMaxWidth()) { Text("AGREGAR") }
                                }
                            }
                            5 -> {
                                val total = cart.sumOf { it.price * it.quantity }
                                Column {
                                    Text("Total: $$total", fontSize = 32.sp, fontWeight = FontWeight.Black)
                                    Spacer(Modifier.height(24.dp))
                                    Row {
                                        MethodBtn("Efectivo", paymentMethod == "Efectivo") { paymentMethod = "Efectivo" }
                                        Spacer(Modifier.width(12.dp))
                                        MethodBtn("Tarjeta", paymentMethod == "Tarjeta") { paymentMethod = "Tarjeta" }
                                    }
                                    Spacer(Modifier.height(32.dp))
                                    Button(onClick = { onConfirm(total, paymentMethod) }, modifier = Modifier.fillMaxWidth().height(60.dp)) {
                                        Text("CONFIRMAR PAGO")
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
fun MethodBtn(name: String, selected: Boolean, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        colors = ButtonDefaults.buttonColors(containerColor = if(selected) ActionBlue else Color.LightGray),
        modifier = Modifier.height(60.dp)
    ) { Text(name) }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CorteDialog(sales: List<POSSale>, onDismiss: () -> Unit, onConfirm: () -> Unit) {
    val total = sales.filter { it.status == "Cobrada" }.sumOf { it.amount }
    val cash = sales.filter { it.status == "Cobrada" && it.method == "Efectivo" }.sumOf { it.amount }
    val card = sales.filter { it.status == "Cobrada" && it.method == "Tarjeta" }.sumOf { it.amount }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("¿Cerrar Corte?", fontWeight = FontWeight.Black) },
        text = {
            Column {
                Text("Ventas Totales: $$total")
                Text("Efectivo: $$cash")
                Text("Tarjeta: $$card")
                Text("Canceladas: ${sales.count { it.status == "Cancelada" }}")
                Spacer(Modifier.height(16.dp))
                Text("Esta acción registrará el corte y reiniciará la caja.", color = Color.Gray, fontSize = 12.sp)
            }
        },
        confirmButton = {
            Button(onClick = onConfirm, colors = ButtonDefaults.buttonColors(containerColor = Color.Red)) { Text("HACER CORTE") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("REGRESAR") }
        }
    )
}
