package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class Part10Activity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                AppWidgetConceptScreen()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppWidgetConceptScreen() {
    val scrollState = rememberScrollState()

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = { Text("App Widget Concept") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp)
                .verticalScroll(scrollState)
        ) {
            Text(
                text = "📱 การสร้าง App Widget (Android)",
                style = MaterialTheme.typography.headlineMedium,
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 16.dp)
            )

            Text(
                text = "📌 Concept: App Widget คืออะไร?",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            Text(
                text = "App Widget คือชิ้นส่วน UI หรือแอปพลิเคชันขนาดย่อที่เราสามารถนำไปแปะไว้บนหน้าจอหลัก (Home Screen) ของมือถือได้ เพื่อให้ผู้ใช้สามารถเชื่อมต่อกับหน้าต่างแอป ดูข้อมูลอัปเดต หรือกดปุ่มสั่งงานบางอย่างได้อย่างรวดเร็ว โดยที่คุณไม่จำเป็นจะต้องกดเปิดแอปพลิเคชันขึ้นมาเต็มจอ (ตัวอย่างเช่น วิดเจ็ตดูสภาพอากาศ นาฬิกา หรือเครื่องเล่นอัดเสียง)",
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.padding(bottom = 24.dp)
            )

            Text(
                text = "🛠️ ส่วนประกอบของ App Widget (แบบดั้งเดิม)",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            Text(
                text = "1. AppWidgetProviderInfo (XML): ไฟล์กำหนดค่าตั้งต้น เช่น ขนาดเล็กสุด (minWidth/minHeight) หมวดหมู่ และความถี่ในการอัปเดตข้อมูล\n\n" +
                        "2. AppWidgetProvider (BroadcastReceiver): คลาสของ Kotlin/Java ที่สืบทอดมาคอยรับ Event ว่าผู้ใช้เพิ่งเอา Widget วางลงบน Home Screen แล้วนะ, กดสั่งลบแล้ว, หรือถึงเวลาที่ระบบบังคับให้อัปเดตข้อมูล (onUpdate) แล้ว\n\n" +
                        "3. Widget Layout (XML): การสร้างหน้าตาของคลาสสิก Widget จะใช้ระบบที่เรียกว่า 'RemoteViews' ซึ่งทำงานข้าม Process และมีข้อจำกัดสูงมากๆ คือจะรองรับ View พื้นฐานเพียงบางตัวเท่านั้น (เช่น TextView, ImageView, Button) โดยไม่สามารถใช้ View ยิบย่อยหรือ Compose ธรรมดาได้โดยตรง",
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier
                    .background(MaterialTheme.colorScheme.surfaceVariant, shape = MaterialTheme.shapes.medium)
                    .padding(16.dp)
                    .padding(bottom = 8.dp)
            )
            
            Text(
                text = "🚀 ยุคใหม่ด้วย Jetpack Glance",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.padding(top = 24.dp, bottom = 8.dp)
            )

            Text(
                text = "เนื่องจากการเขียนข้าม Process ด้วย RemoteViews ดั้งเดิมมีความยุ่งยาก Google จึงปล่อยไลบรารีชื่อ 'Jetpack Glance' ออกมา ซึ่งช่วยให้เราสามารถเรียกใช้ไวยากรณ์คล้ายหน้า Compose ธรรมดาเพื่อมาวาดหน้าตาลงบนจอ Widget ได้ แล้วทางไลบรารีจะรับหน้าที่แปลงโค้ดของเราเป็น RemoteViews ส่งให้หน้าจอ Home Screen เองอัตโนมัติเบื้องหลัง ช่วยลดเรื่องปวดหัวไปได้เยอะมาก!\n\n" +
                        "ถ้าคุณถนัด Compose แล้วล่ะก็ การสร้าง Widget ด้วย Glance จะเป็นเรื่องเล็กไปเลยครับ",
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.padding(bottom = 16.dp)
            )
        }
    }
}
