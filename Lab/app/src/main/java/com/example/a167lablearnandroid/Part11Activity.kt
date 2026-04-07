package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.animateColor
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class Part11Activity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                SkeletonLoadingScreen()
            }
        }
    }
}

@Composable
fun SkeletonLoadingScreen() {
    val scrollState = rememberScrollState()

    Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp)
                .verticalScroll(scrollState)
        ) {
            Text(
                text = "💀 Concept: Skeleton Loading",
                style = MaterialTheme.typography.headlineMedium,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(bottom = 16.dp)
            )

            Text(
                text = "Skeleton Loading (หรือบางทีเรียกว่า Shimmer Effect) เป็นเทคนิคการออกแบบ UI เพื่อบอกผู้ใช้ว่า 'ข้อมูลกำลังโหลดอยู่นะ' และชี้เป็นนัยๆ ให้เห็นด้วยว่า 'โครงสร้าง' ของเนื้อหาที่จะปรากฏขึ้นจะมีรูปร่างและขนาดประมาณไหน \n\n" +
                        "มันมีข้อดีกว่ารูปลูกศรหมุนโหลดข้อมูลแบบเก่าๆ (Circular Progress Indicator) ตรงที่ Skeleton จะช่วยให้การรอคอยข้อมูลรู้สึกไม่นานจนเกินไปในเชิงจิตวิทยาเพราะเห็นโครงร่างว่าข้อมูลใกล้มาแล้ว และที่สำคัญยังป้องกันไม่ให้หน้าจอทั้งหมดเลื่อนหรือกระตุกสั่น (Layout Shift) วินาทีที่ข้อมูลถูกดาวน์โหลดมาถมใส่หน้าจอสำเร็จ\n\n" +
                        "ใน Compose ถ้ายากใช้แบบง่ายๆ ไม่ต้องพึ่งพิงไลบรารีอื่น เราสามารถใช้ 'infiniteTransition' ช่วยสร้างสีเทาที่สว่างสลับมืดแบบวนลูป เพื่อแปะทับกล่องพื้นที่เอาไว้ชั่วคราวดังตัวอย่างด้านล่างได้ครับ",
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.padding(bottom = 24.dp)
            )

            // เส้นคั่น
            Spacer(modifier = Modifier.height(16.dp))

            Text(text = "ตัวอย่างการโชว์ Skeleton UI แบบโครงฟีดข่าว", style = MaterialTheme.typography.titleMedium)
            Spacer(modifier = Modifier.height(16.dp))

            // จำลอง List ของ Skeleton 3 อัน
            repeat(4) {
                SkeletonListItem()
                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }
}

@Composable
fun SkeletonListItem() {
    // แอนิเมชันให้สีเทากะพริบจาง-เข้ม เรื่อยๆ ไม่เข้าที่
    val infiniteTransition = rememberInfiniteTransition(label = "skeleton_anim")
    val color by infiniteTransition.animateColor(
        initialValue = Color.LightGray.copy(alpha = 0.3f),
        targetValue = Color.LightGray.copy(alpha = 0.8f),
        animationSpec = infiniteRepeatable(
            animation = tween(800, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse // ถอยจาง-เข้มไปมา
        ),
        label = "skeleton_color"
    )

    Row(verticalAlignment = Alignment.CenterVertically) {
        // วงกลม (เหมือนรูปโปรไฟล์)
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(CircleShape)
                .background(color)
        )
        Spacer(modifier = Modifier.width(16.dp))
        Column(modifier = Modifier.weight(1f)) {
            // เส้นข้อความแบบยาว
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.8f) // เอาความกว้าง 80% ของพื้นที่ช่องนี้
                    .height(16.dp)
                    .clip(RoundedCornerShape(4.dp))
                    .background(color) // ระบายด้วยสีที่กระพริบ
            )
            Spacer(modifier = Modifier.height(8.dp))
            // เส้นข้อความแบบสั้น
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.5f) // กว้าง 50%
                    .height(14.dp)
                    .clip(RoundedCornerShape(4.dp))
                    .background(color)
            )
        }
    }
}
