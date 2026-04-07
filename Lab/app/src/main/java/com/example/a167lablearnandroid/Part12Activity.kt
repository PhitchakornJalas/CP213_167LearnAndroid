package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class Part12Activity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                DialogAndBottomSheetScreen()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DialogAndBottomSheetScreen() {
    // 1. ควบคุม State ให้อยู่ภายในการควบคุมว่าจะเปิดหน้าต่างอันไหนขึ้นมา
    var showBottomSheet by remember { mutableStateOf(false) }
    var showDialog by remember { mutableStateOf(false) }
    
    // ไว้ใช้คุมพฤติกรรมการเปิด/ปิด การสไลด์นิ้วที่สมูทขึ้นใน Material 3
    val bottomSheetState = rememberModalBottomSheetState()
    val scrollState = rememberScrollState()

    Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp)
                .verticalScroll(scrollState),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "💬 Popup Concepts",
                style = MaterialTheme.typography.headlineMedium,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.align(Alignment.Start).padding(bottom = 24.dp)
            )

            // ---------------------------------------------------------
            // ⭐️ Middle Dialog Section
            // ---------------------------------------------------------
            Text(
                text = "1. Middle Dialog (AlertDialog)",
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.align(Alignment.Start)
            )
            Text(
                text = "คือป๊อปอัปแจ้งเตือนที่แทรกตัวขึ้นมาตรงกลางหน้าจอมือถือ มักใช้เพื่อขัดจังหวะผู้ใช้ โดยบังคับให้ผู้ใช้ต้องอ่านข้อมูลและตัดสินใจกดตอบสนองก่อน ถึงจะให้ไปทำอย่างอื่นต่อได้ (Blocking action) เช่น กรณีฉุกเฉิน 'ระบบผิดพลาด', 'คุณแน่ใจหรือไม่ว่าจะลบ?' เป็นต้น",
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.align(Alignment.Start).padding(top = 8.dp, bottom = 12.dp)
            )
            Button(onClick = { showDialog = true }, modifier = Modifier.fillMaxWidth()) {
                Text("เปิด Middle Dialog")
            }

            Spacer(modifier = Modifier.height(40.dp))

            // ---------------------------------------------------------
            // ⭐️ Modal Bottom Sheet Section
            // ---------------------------------------------------------
            Text(
                text = "2. Modal Bottom Sheet",
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.align(Alignment.Start)
            )
            Text(
                text = "คือหน้าต่างเมนูที่เลื่อนทะลุโผล่ขึ้นมาจากด้านล่างสุดของหน้าจอ ใช้เพื่อให้ตัวเลือกหรือข้อมูลเพิ่มเติมแก่ผู้ใช้ รูปแบบนี้จะให้ความรู้สึกอึดอัดน้อยกว่า Dialog ตัวบน เหมาะกับการใส่ฟังก์ชันหลายๆ เมนู หรือใช้แสดงฟิลเตอร์กรองสินค้า",
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.align(Alignment.Start).padding(top = 8.dp, bottom = 12.dp)
            )
            Button(onClick = { showBottomSheet = true }, modifier = Modifier.fillMaxWidth()) {
                Text("เปิด Bottom Sheet")
            }
        }
    }

    // ==========================================
    // การเรียกวาด Component พวกนี้จะเป็นอิสระ ปล่อยตาม State (ลอยอยู่มุมไหนก็ได้ในโค้ด)
    // ==========================================

    // -- การแสดงผล Middle Dialog --
    if (showDialog) {
        AlertDialog(
            onDismissRequest = { showDialog = false }, // สั่งให้ปิดถ้าแตะด้านนอก
            confirmButton = {
                TextButton(onClick = { showDialog = false }) { Text("รับแซ่บ") }
            },
            dismissButton = {
                TextButton(onClick = { showDialog = false }) { Text("ยกเลิก") }
            },
            title = { Text("คำเตือนสำคัญจากระบบ!") },
            text = { Text("นี่คือตัวอย่างของ Dialog ที่ลอยอยู่กลางจอ ซึ่งมันทำให้ผู้ใช้วอกแวกไม่ได้จนกว่าจะกดปุ่มทิ้งไป ถ้าคุณไม่กดรับทราบ มันก็จะไม่หายไปไหน") }
        )
    }

    // -- การแสดงผล Bottom Sheet --
    if (showBottomSheet) {
        ModalBottomSheet(
            onDismissRequest = { showBottomSheet = false }, // ปิดเมื่อเอานิ้วปัดลงหรือแตะด้านนอก
            sheetState = bottomSheetState
        ) {
            // ข้อมูลที่อยู่ในแผ่นกระดาษเลื่อนขึ้น
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text("เมนูลับใต้ดิน ยินดีต้อนรับ!", style = MaterialTheme.typography.titleLarge)
                Text("คุณสามารถใส่ตัวเลือกอย่างเช่น 'แชร์หน้าเว็บ', 'คัดลอกลิงก์', หรือแม้แต่ปุ่มลบเนื้อหา ได้ในหน้านี้อย่างเป็นระเบียบ ส่วนช่องทางการปิดก็แค่รูดหน้าจอนี้กดปัดกลับลงไปด้านล่างครับ", style = MaterialTheme.typography.bodyLarge)
                Spacer(modifier = Modifier.height(32.dp)) 
            }
        }
    }
}
