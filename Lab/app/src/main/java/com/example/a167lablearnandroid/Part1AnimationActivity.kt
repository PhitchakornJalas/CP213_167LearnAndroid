package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class Part1AnimationActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    LikeButtonScreen(modifier = Modifier.padding(innerPadding))
                }
            }
        }
    }
}

@Composable
fun LikeButtonScreen(modifier: Modifier = Modifier) {
    // State สำหรับสถานะปุ่ม Like
    var isLiked by remember { mutableStateOf(false) }
    
    // State สำหรับจับ Event การกดปุ่ม (ใช้ทำ Scale animation)
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()

    // 1. Scale Animation: ขยายเมื่อกด แล้วกลับมาขนาดเดิม
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 1.2f else 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "scale"
    )

    // 2. Color Animation: สีเทา เป็น สีชมพู
    val backgroundColor by animateColorAsState(
        targetValue = if (isLiked) Color(0xFFE91E63) else Color.LightGray,
        label = "color"
    )

    Column(
        modifier = modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Button(
            onClick = { isLiked = !isLiked },
            interactionSource = interactionSource,
            colors = ButtonDefaults.buttonColors(
                containerColor = backgroundColor,
                contentColor = if (isLiked) Color.White else Color.Black
            ),
            modifier = Modifier.scale(scale)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                // 3. AnimatedVisibility: โผล่ขึ้นมาข้างๆ ข้อความเมื่อ Liked
                AnimatedVisibility(visible = isLiked) {
                    Icon(
                        imageVector = Icons.Filled.Favorite,
                        contentDescription = "Heart Icon",
                        modifier = Modifier.padding(end = 8.dp)
                    )
                }
                Text(text = if (isLiked) "Liked" else "Like")
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun LikeButtonPreview() {
    _167LabLearnAndroidTheme {
        LikeButtonScreen()
    }
}