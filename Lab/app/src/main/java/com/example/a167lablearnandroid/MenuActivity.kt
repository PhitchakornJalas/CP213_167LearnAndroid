package com.example.a167lablearnandroid

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.dp
import androidx.core.app.ActivityOptionsCompat
import com.example.a167lablearnandroid.architecture.mvc.MvcCounterActivity
import com.example.a167lablearnandroid.architecture.mvi.MviCounterActivity
import com.example.a167lablearnandroid.architecture.mvp.MvpCounterActivity
import com.example.a167lablearnandroid.architecture.mvvm.MvvmCounterActivity

class MenuActivity : ComponentActivity() {

    // รูปแบบของ Transition ที่มีให้เลือกใช้งาน
    enum class ActivityTransitionType(val desc: String) {
        FADE("Fade In/Out"),
        SLIDE("Slide Left/Right"),
        SCALE_UP("Scale Up"),
        CLIP_REVEAL("Clip Reveal"),
        DEFAULT("Default")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val view = LocalView.current // สำหรับอ้างอิง View ดั้งเดิมของหน้าจอ (ใช้รัน Scale/Reveal Transition)
            val scrollState = rememberScrollState() // เผื่อปุ่มมีเยอะจนล้นหน้าจอ

            // ฟังก์ชันส่งไปหน้าใหม่ พร้อมปรับเปลี่ยนแอนิเมชันตามรูปแบบที่ร้องขอ
            val navigateWithTransition = { targetClass: Class<*>, transition: ActivityTransitionType ->
                val intent = Intent(this@MenuActivity, targetClass)
                
                // ใช้ ActivityOptionsCompat.make... เพื่อสร้าง Bundle ควบคุมแอนิเมชันตอนเปิดหน้า
                val bundle = when (transition) {
                    ActivityTransitionType.FADE -> ActivityOptionsCompat.makeCustomAnimation(
                        this@MenuActivity, android.R.anim.fade_in, android.R.anim.fade_out
                    ).toBundle()
                    
                    ActivityTransitionType.SLIDE -> ActivityOptionsCompat.makeCustomAnimation(
                        this@MenuActivity, android.R.anim.slide_in_left, android.R.anim.slide_out_right
                    ).toBundle()
                    
                    ActivityTransitionType.SCALE_UP -> ActivityOptionsCompat.makeScaleUpAnimation(
                        view, 0, 0, view.width, view.height
                    ).toBundle()
                    
                    ActivityTransitionType.CLIP_REVEAL -> ActivityOptionsCompat.makeClipRevealAnimation(
                        view, 0, 0, view.width, view.height
                    ).toBundle()
                    
                    ActivityTransitionType.DEFAULT -> null // ไม่ตั้งข้อมูลใน Bundle เพื่อปล่อยตามระบบ
                }
                
                // ส่ง Bundle นี้เข้าไปให้ Android รู้ว่าต้องทำแอนิเมชันกระโดดเข้าหน้าเป็นแบบไหน
                startActivity(intent, bundle)
            }

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    // เพิ่ม padding เพื่อให้เว้นระยะจาก Edge to Edge
                    .padding(vertical = 48.dp, horizontal = 16.dp) 
                    .verticalScroll(scrollState)
            ) {
                // สลับการเรียกใช้ Transition ประเภทต่างๆ แบ่งๆ กันไปตามหน้า เพื่อเป็น Demo ว่าตัวไหนคือรูปทรงอะไร
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(MainActivity::class.java, ActivityTransitionType.FADE) }) {
                    Text("RPGCaardActivity - [${ActivityTransitionType.FADE.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(ListActivity::class.java, ActivityTransitionType.SLIDE) }) {
                    Text("Pokemon - [${ActivityTransitionType.SLIDE.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(MainActivity2::class.java, ActivityTransitionType.SCALE_UP) }) {
                    Text("LifeCycleComposeActivity - [${ActivityTransitionType.SCALE_UP.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(MvcCounterActivity::class.java, ActivityTransitionType.CLIP_REVEAL) }) {
                    Text("MvcCounterActivity - [${ActivityTransitionType.CLIP_REVEAL.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(MviCounterActivity::class.java, ActivityTransitionType.DEFAULT) }) {
                    Text("MviCounterActivity - [${ActivityTransitionType.DEFAULT.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(MvpCounterActivity::class.java, ActivityTransitionType.FADE) }) {
                    Text("MvpCounterActivity - [${ActivityTransitionType.FADE.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(MvvmCounterActivity::class.java, ActivityTransitionType.SLIDE) }) {
                    Text("MvvmCounterActivity - [${ActivityTransitionType.SLIDE.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(SharedPreferencesActivity::class.java, ActivityTransitionType.SCALE_UP) }) {
                    Text("SharedPreferencesActivity - [${ActivityTransitionType.SCALE_UP.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(GalleryActivity::class.java, ActivityTransitionType.CLIP_REVEAL) }) {
                    Text("Gallery & Permission - [${ActivityTransitionType.CLIP_REVEAL.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(SensorActivity::class.java, ActivityTransitionType.DEFAULT) }) {
                    Text("Sensor MVVM - [${ActivityTransitionType.DEFAULT.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(Part1AnimationActivity::class.java, ActivityTransitionType.FADE) }) {
                    Text("Part1AnimationActivity - [${ActivityTransitionType.FADE.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(Part2ComplexListsPaginationActivity::class.java, ActivityTransitionType.SLIDE) }) {
                    Text("Part2ComplexListsPaginationActivity - [${ActivityTransitionType.SLIDE.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(Part3GraphicsEffectsCanvasActivity::class.java, ActivityTransitionType.SCALE_UP) }) {
                    Text("Part3GraphicsEffectsCanvasActivity - [${ActivityTransitionType.SCALE_UP.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(Part4AdvancedGesturesInteractiveUIActivity::class.java, ActivityTransitionType.CLIP_REVEAL) }) {
                    Text("Part4AdvancedGesturesInteractiveUIActivity - [${ActivityTransitionType.CLIP_REVEAL.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(Part5ComposeSideEffectsActivity::class.java, ActivityTransitionType.DEFAULT) }) {
                    Text("Part5ComposeSideEffectsActivity - [${ActivityTransitionType.DEFAULT.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(Part6ViewInteroperabilityActivity::class.java, ActivityTransitionType.FADE) }) {
                    Text("Part6ViewInteroperabilityActivity - [${ActivityTransitionType.FADE.desc}]")
                }
                Button(modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp), onClick = { navigateWithTransition(Part8AdaptiveLayoutsActivity::class.java, ActivityTransitionType.SLIDE) }) {
                    Text("Part8AdaptiveLayoutsActivity - [${ActivityTransitionType.SLIDE.desc}]")
                }
            }
        }
    }
}

// มาเรียนครับบบบ 24 FEB