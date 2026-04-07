package com.example.a167lablearnandroid

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.glance.Button
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.state.PreferencesGlanceStateDefinition
import androidx.glance.text.Text
import androidx.glance.text.TextStyle

// 1. ตัวรับ Event จากระบบปฏิบัติการ Android 
class Part10WidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = Part10Widget()
}

// 2. โครงสร้าง Widget หลัก
class Part10Widget : GlanceAppWidget() {
    // ระบุว่าจะใช้ Preferences DataStore ในการจำค่าสะสม
    override val stateDefinition = PreferencesGlanceStateDefinition

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            // ดึงข้อมูล State ล่าสุดออกมา 
            val prefs = currentState<Preferences>()
            val count = prefs[countKey] ?: 0

            GlanceWidgetUI(count)
        }
    }
}

val countKey = intPreferencesKey("widget_count_key")

// 3. วาด UI (โครงสร้างคำสั่งจะคล้ายๆ Compose ปกติ)
@Composable
fun GlanceWidgetUI(count: Int) {
    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Color(0xFFE3F2FD)) // พื้นหลังสีฟ้าอ่อน
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "✨ Jetpack Glance Widget",
            style = TextStyle(color = androidx.glance.unit.ColorProvider(Color.Black))
        )
        Text(
            text = "Count: $count",
            modifier = GlanceModifier.padding(top = 8.dp, bottom = 8.dp),
            style = TextStyle(color = androidx.glance.unit.ColorProvider(Color.DarkGray))
        )
        // ปุ่มเมื่อกดเรียกให้เปลี่ยนค่า (โดยไม่ปลุกหน้าแอปเต็ม)
        Button(
            text = "Increment (+)",
            onClick = actionRunCallback<IncrementActionCallback>()
        )
    }
}

// 4. Callback สำหรับอัปเดต State ให้ตัวเลขเพิ่มขึ้น และรีเฟรช Widget รูปภาพ
class IncrementActionCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        updateAppWidgetState(context, PreferencesGlanceStateDefinition, glanceId) { prefs ->
            val currentCount = prefs[countKey] ?: 0
            prefs.toMutablePreferences().apply {
                this[countKey] = currentCount + 1
            }
        }
        // สั่งวาด UI บน Home Screen ใหม่
        Part10Widget().update(context, glanceId)
    }
}
