package com.example.a167lablearnandroid

import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.ViewModel
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

// 1. สร้าง ViewModel เพื่อเก็บ State URL (เริ่มที่ Google)
class WebViewModel : ViewModel() {
    private val _url = MutableStateFlow("https://www.google.com")
    val url: StateFlow<String> = _url.asStateFlow()

    fun updateUrl(newUrl: String) {
        // เพิ่ม prefix http เข้าไปอัตโนมัติหากไม่มีเพื่อลดข้อผิดพลาด
        val validUrl = if (newUrl.startsWith("http://") || newUrl.startsWith("https://")) {
            newUrl
        } else {
            "https://$newUrl"
        }
        _url.value = validUrl
    }
}

class Part6ViewInteroperabilityActivity : ComponentActivity() {
    private val viewModel: WebViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    WebViewScreen(
                        viewModel = viewModel,
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@Composable
fun WebViewScreen(viewModel: WebViewModel, modifier: Modifier = Modifier) {
    // อ่านค่า currentUrl ออกมาจาก ViewModel
    val currentUrl by viewModel.url.collectAsState()
    
    // TextField State สำหรับรับค่าที่ผู้ใช้กำลังพิมพ์ (Local State)
    var inputText by remember { mutableStateOf(currentUrl) }

    Column(modifier = modifier.fillMaxSize()) {
        // แถบด้านบน: TextField พิมพ์ URL และปุ่ม Go
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            TextField(
                value = inputText,
                onValueChange = { inputText = it },
                modifier = Modifier.weight(1f),
                label = { Text("Enter URL") },
                singleLine = true
            )
            Button(
                onClick = { viewModel.updateUrl(inputText) },
                modifier = Modifier.padding(start = 8.dp)
            ) {
                Text("Go")
            }
        }

        // 2. เรียกใช้งานฝั่ง Android View ดั้งเดิม באמצעות AndroidView Composable
        AndroidView(
            modifier = Modifier.fillMaxSize(),
            // factory ใช้สำหรับ 'สร้าง' View ดั้งเดิม ครั้งแรกและครั้งเดียว (เหมือน onCreate ของ View)
            factory = { context ->
                WebView(context).apply {
                    // 3. ป้องกันไม่ให้เพจเด้งไปเปิดที่เบราว์เซอร์ภายนอกแอป (ให้มันโหลดในจอเรา)
                    webViewClient = WebViewClient()
                    
                    // เปิด JavaScript (ตามเว็บยุคใหม่ทั่วไปต้องการ)
                    settings.javaScriptEnabled = true
                }
            },
            // update จะทำงานทุกครั้งที่มีการ Re-composition ซึ่งเป็นผลกระทบมาจาก State ด้านบน
            // ตรงนี้สำคัญมาก โค้ดที่ไว้รับ State จาก Compose แล้วป้อนกลับให้ Android View ต้องอยู่ตรงนี้!
            update = { webView ->
                // 4. สั่งให้ WebView ดั้งเดิม โหลด URL ใหม่ตาม State ที่ถูกกดมา
                webView.loadUrl(currentUrl)
            }
        )
    }
}

@Preview(showBackground = true)
@Composable
fun WebViewScreenPreview() {
    _167LabLearnAndroidTheme {
        WebViewScreen(viewModel = WebViewModel())
    }
}