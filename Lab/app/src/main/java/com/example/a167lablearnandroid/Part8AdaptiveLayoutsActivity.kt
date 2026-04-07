package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class Part8AdaptiveLayoutsActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    AdaptiveProfileScreen(modifier = Modifier.padding(innerPadding))
                }
            }
        }
    }
}

@Composable
fun AdaptiveProfileScreen(modifier: Modifier = Modifier) {
    // 1. เรียกใช้ BoxWithConstraints เพื่อตรวจสอบขนาดหน้าจอแบบ Real-time
    BoxWithConstraints(modifier = modifier
        .fillMaxSize()
        .padding(24.dp)) {
        
        // 2. ถ้าความกว้างน้อยกว่า 600.dp (หน้าจอมือถือ หรือแนวตั้ง) ให้วางแบบ Column
        if (maxWidth < 600.dp) {
            Column(
                modifier = Modifier.fillMaxSize(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                ProfileImage(modifier = Modifier.size(150.dp))
                Spacer(modifier = Modifier.height(32.dp))
                ProfileDetails(modifier = Modifier.fillMaxWidth())
            }
        } 
        // 3. ถ้ามากกว่า 600.dp (แท็บเล็ต หรือแนวนอน) ให้วางแบบ Row
        else {
            Row(
                modifier = Modifier.fillMaxSize(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                ProfileImage(modifier = Modifier.size(200.dp))
                Spacer(modifier = Modifier.width(48.dp))
                // จัดสัดส่วนข้อมูลส่วนตัวให้กินพื้นที่ที่เหลือด้วย weight
                ProfileDetails(modifier = Modifier.weight(1f))
            }
        }
    }
}

@Composable
fun ProfileImage(modifier: Modifier = Modifier) {
    // กล่องสมมติสีเทาแทนรูปโปรไฟล์
    Box(
        modifier = modifier
            .clip(CircleShape)
            .background(Color.LightGray),
        contentAlignment = Alignment.Center
    ) {
        Text("Profile Image", color = Color.DarkGray)
    }
}

@Composable
fun ProfileDetails(modifier: Modifier = Modifier) {
    // Text อธิบายข้อมูลส่วนตัว
    Column(modifier = modifier) {
        Text(
            text = "John Doe",
            style = MaterialTheme.typography.displaySmall
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Software Engineer & Designer. I love building responsive layouts and scalable architectures using modern Android development tools like Jetpack Compose.",
            style = MaterialTheme.typography.bodyLarge,
            color = Color.Gray
        )
    }
}

// Preview 2 แบบ: เลียนแบบ Mobile Portrait
@Preview(showBackground = true, widthDp = 400)
@Composable
fun AdaptiveProfilePreviewMobile() {
    _167LabLearnAndroidTheme {
        AdaptiveProfileScreen()
    }
}

// Preview: เลียนแบบ Tablet Landscape
@Preview(showBackground = true, widthDp = 800)
@Composable
fun AdaptiveProfilePreviewTablet() {
    _167LabLearnAndroidTheme {
        AdaptiveProfileScreen()
    }
}
