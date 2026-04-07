package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.LargeTopAppBar
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.unit.dp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class Part9Activity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                CollapsingToolbarScreen()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CollapsingToolbarScreen() {
    // 1. กำหนด ScrollBehavior แบบ exitUntilCollapsed
    // หมายความว่า เวลาที่เราไถจอลงมา TopAppBar ใหญ่ๆ มันจะค่อยๆ หดเนื้อที่ลงมาเรื่อยๆ จนเหลือแค่ขนาดปกติ
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()

    Scaffold(
        modifier = Modifier
            .fillMaxSize()
            // 2. สำคัญมาก! ต้องผูก modifier nestedScroll เข้ากับแอป 
            // เพื่อดักจับว่าตัว Content ด้านล่างกำลังถูกไถไปทิศทางไหน แล้วส่งข้อมูลนั้นไปหลอกให้ ScrollBehavior หดหัว App Bar
            .nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            LargeTopAppBar(
                title = { Text("Collapsing Toolbar") },
                scrollBehavior = scrollBehavior,
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    scrolledContainerColor = MaterialTheme.colorScheme.surface,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        }
    ) { innerPadding ->
        // ใส่ของยาวๆ ลงใน Content ด้านล่าง เพื่อให้เกิดพื้นที่ว่างพอให้ไถขึ้นลง
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(16.dp)
        ) {
            item {
                Text(
                    text = "🎯 Concept: Collapsing Toolbar",
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.padding(bottom = 8.dp)
                )
            }
            item {
                Text(
                    text = "Collapsing หมายถึงรูปแบบหนึ่งของ Navigation UI ที่เมื่อเรามีรูปปกใหญ่ๆ หรือแถบหัวข้อใหญ่ๆ (Large/Medium TopAppBar) หากผู้ใช้เริ่มเลื่อนไถหน้าจอลงมาเสพคอนเทนต์ แถบใหญ่ๆ เหล่านั้นจะทำการ 'หดตัว' (Collapse) แบบมีแอนิเมชันรวบเข้าหาขอบบนอัตโนมัติ \n\n" +
                            "ประโยชน์คือ ทำให้ประหยัดที่ว่างเพื่อให้ผู้ใช้มองเห็นข้อมูลสำคัญได้เต็มหน้าจอมือถือมากขึ้น แต่ในขณะเดียวกันก็สามารถเหลือชื่อหน้าจอติดขอบบนไว้ได้ ไม่ได้ปลิวหายไปทั้งหมด (เทคนิคการใช้ exitUntilCollapsed)\n\n" +
                            "ใน Jetpack Compose เราพึ่งพา TopAppBarDefaults.*ScrollBehavior ควบคู่กับการแปะ modifier .nestedScroll ไปที่ตัว Scaffold ครับ",
                    style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier.padding(bottom = 32.dp)
                )
            }
            
            // สร้างกล่องข้อมูลดัมมี่ เพื่อให้มีของยาวพอจะให้ไถหน้าจอลงมาได้
            items(30) { index ->
                Text(
                    text = "Mock Content List Item ${index + 1}",
                    modifier = Modifier.padding(vertical = 12.dp),
                    style = MaterialTheme.typography.bodyMedium
                )
            }
        }
    }
}
