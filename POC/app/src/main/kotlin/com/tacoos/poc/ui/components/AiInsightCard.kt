package com.tacoos.poc.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun AiInsightCard(
    message: String,
    visible: Boolean,
    onClose: () -> Unit
) {
    AnimatedVisibility(
        visible = visible,
        enter = expandVertically(),
        exit = shrinkVertically()
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            shape = RoundedCornerShape(24.dp),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Box(
                modifier = Modifier
                    .background(
                        Brush.horizontalGradient(
                            colors = listOf(
                                Color(0xFF6A11CB), // Purple AI color
                                Color(0xFF2575FC)  // Blue AI color
                            )
                        )
                    )
                    .padding(16.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.AutoAwesome,
                        contentDescription = "AI Insight",
                        tint = Color.White,
                        modifier = Modifier.size(28.dp)
                    )
                    
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "TACO AI INSIGHT",
                            color = Color.White.copy(alpha = 0.8f),
                            fontWeight = FontWeight.Bold,
                            fontSize = 12.sp,
                            letterSpacing = 1.2.sp
                        )
                        Text(
                            text = message,
                            color = Color.White,
                            fontWeight = FontWeight.Medium,
                            fontSize = 14.sp,
                            lineHeight = 20.sp
                        )
                    }

                    IconButton(
                        onClick = onClose,
                        modifier = Modifier.align(Alignment.Top)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Cerrar",
                            tint = Color.White.copy(alpha = 0.7f)
                        )
                    }
                }
            }
        }
    }
}
