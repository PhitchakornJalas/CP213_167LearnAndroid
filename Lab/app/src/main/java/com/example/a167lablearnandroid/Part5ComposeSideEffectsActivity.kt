package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.launch

// 1. สร้าง ViewModel ใช้ Channel ส่งค่าเป็นลักษณะ One-time event
class SideEffectViewModel : ViewModel() {
    // Channel เหมาะที่สุดสำหรับการส่ง Event ที่เกิดขึ้นแค่ครั้งเดียว ไม่จำเป็นต้องจำ State (อย่างการโชว์ Snackbar)
    private val _errorChannel = Channel<String>()
    val errorFlow = _errorChannel.receiveAsFlow()

    fun triggerError() {
        viewModelScope.launch {
            _errorChannel.send("เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์! (จำลอง)")
        }
    }
}

class Part5ComposeSideEffectsActivity : ComponentActivity() {
    private val viewModel: SideEffectViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                SideEffectScreen(viewModel = viewModel)
            }
        }
    }
}

@Composable
fun SideEffectScreen(viewModel: SideEffectViewModel) {
    // 2. ใช้ SnackbarHostState เอาไว้เป็นตัวคุมคิวของ Snackbar
    val snackbarHostState = remember { SnackbarHostState() }

    // 3. ใช้ LaunchedEffect ในวงจร (Scope) ของ Compose เพื่อ Observe Event
    // ค่า Key ใส่เป็น Unit เพื่อให้ทำงานแค่ตอนแรกที่เปิดหน้า (และอยู่ยืนยาวไปเรื่อยๆ จนหว่าจะหลุดคอมโพส)
    LaunchedEffect(Unit) {
        viewModel.errorFlow.collect { errorMessage ->
            // โชว์ Snackbar โดยไม่ต้องเก็บเป็น State ทั่วไป ทำให้ไม่มีปัญหาว่าหมุนจอแล้วเด้งซ้ำ
            snackbarHostState.showSnackbar(
                message = errorMessage,
                actionLabel = "รับทราบ"
            )
        }
    }

    // ยัด SnackbarHost เข้ามาใน Scaffold
    Scaffold(
        modifier = Modifier.fillMaxSize(),
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentAlignment = Alignment.Center
        ) {
            // 4. ปุ่มสำหรับขอกระตุ้น Event จาก ViewModel
            Button(onClick = { viewModel.triggerError() }) {
                Text("Trigger Error ซักหน่อย!")
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun SideEffectPreview() {
    _167LabLearnAndroidTheme {
        SideEffectScreen(viewModel = SideEffectViewModel())
    }
}