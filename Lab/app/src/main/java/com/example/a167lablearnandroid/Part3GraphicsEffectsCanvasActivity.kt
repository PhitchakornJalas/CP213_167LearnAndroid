package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class Part3GraphicsEffectsCanvasActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                text = "Donut Chart Animation",
                                style = MaterialTheme.typography.headlineMedium
                            )
                            Spacer(modifier = Modifier.height(32.dp))
                            
                            // 1. เรียกใช้งาน DonutChart ใส่ค่าเปอร์เซ็นต์และสี
                            DonutChart(
                                values = listOf(30f, 40f, 30f),
                                colors = listOf(
                                    Color(0xFFE91E63), // Pink
                                    Color(0xFF2196F3), // Blue
                                    Color(0xFFFFC107)  // Amber
                                ),
                                modifier = Modifier.size(250.dp)
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun DonutChart(
    values: List<Float>,
    colors: List<Color>,
    modifier: Modifier = Modifier
) {
    // 3. เริ่มต้น Animation ค่อยๆ วาดตั้งแต่ 0 ถึง 360 องศา (แทนค่าด้วยเลข 0f ถึง 1f สัดส่วน)
    val sweepProgress = remember { Animatable(0f) }

    LaunchedEffect(Unit) {
        sweepProgress.animateTo(
            targetValue = 1f,
            animationSpec = tween(durationMillis = 1500, easing = FastOutSlowInEasing)
        )
    }

    // Canvas สำหรับวาดกราฟิก
    Canvas(modifier = modifier) {
        // กำหนดความหนาของวงแหวนโดนัท
        val strokeWidth = 40.dp.toPx()
        val total = values.sum()
        if (total == 0f) return@Canvas
        
        // องศาสูงสุดที่สามารถวาดได้ ณ เวลาของ Animation ปัจจุบัน (0 จนถึง 360)
        val currentMaxSweep = 360f * sweepProgress.value

        var startAngle = -90f // ควบคุมให้เริ่มวาดกราฟจากด้านบนสุดเสมอ
        var accumulatedSweep = 0f

        for (i in values.indices) {
            // คำนวณองศาเต็มๆ (มุมกวาด) ที่ชิ้นส่วนนี้ควรจะเป็น
            val pieceSweep = (values[i] / total) * 360f
            
            // คำนวณองศาที่จะวาดจริง (ดูจากการเคลื่อนที่ของตัว Animation ถ้าถึงขอบเขตที่ชิ้นนี้ถูกวาด ก็จะค่อยๆ เพิ่ม Sweep)
            val drawnSweep = when {
                currentMaxSweep <= accumulatedSweep -> 0f
                currentMaxSweep >= accumulatedSweep + pieceSweep -> pieceSweep
                else -> currentMaxSweep - accumulatedSweep
            }

            if (drawnSweep > 0f) {
                // 2. ใช้วิธีวาดเส้นโค้ง `drawArc` โดยเว้นช่องตรงกลาง (กำหนดผ่าน style = Stroke(...))
                drawArc(
                    color = colors.getOrElse(i) { Color.Gray },
                    startAngle = startAngle,
                    sweepAngle = drawnSweep,
                    useCenter = false, // false = ไม่ลากเส้นเข้าจุดศูนย์กลาง (เป็นวงแหวนแทนวงกลมทึบ/พิซซ่า)
                    style = Stroke(width = strokeWidth, cap = StrokeCap.Butt)
                )
            }
            
            startAngle += pieceSweep
            accumulatedSweep += pieceSweep
        }
    }
}

@Preview(showBackground = true)
@Composable
fun DonutChartPreview() {
    _167LabLearnAndroidTheme {
        Box(modifier = Modifier.padding(24.dp)) {
            DonutChart(
                values = listOf(30f, 40f, 30f),
                colors = listOf(
                    Color(0xFFE91E63),
                    Color(0xFF2196F3),
                    Color(0xFFFFC107)
                ),
                modifier = Modifier.size(200.dp)
            )
        }
    }
}