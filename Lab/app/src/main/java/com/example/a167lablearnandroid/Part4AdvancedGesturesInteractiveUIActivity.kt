package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SwipeToDismissBox
import androidx.compose.material3.SwipeToDismissBoxValue
import androidx.compose.material3.Text
import androidx.compose.material3.rememberSwipeToDismissBoxState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

// 1. ViewModel จัดการ State ของ To-Do List
class TodoViewModel : ViewModel() {
    // สมมติรายการข้อความ 5 รายการตอนเริ่มต้น
    private val _todoList = androidx.compose.runtime.mutableStateListOf(
        "เตรียมตัวอ่านหนังสือสอบ",
        "ทบทวนวิชา Android Development",
        "ทดลองเล่น Jetpack Compose",
        "ทำแบบฝึกหัด Gestures",
        "ส่งงานใน Github"
    )
    val todoList: List<String> get() = _todoList

    fun removeItem(item: String) {
        _todoList.remove(item)
    }
}

class Part4AdvancedGesturesInteractiveUIActivity : ComponentActivity() {
    private val viewModel: TodoViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    TodoListScreen(
                        viewModel = viewModel,
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@Composable
fun TodoListScreen(viewModel: TodoViewModel, modifier: Modifier = Modifier) {
    LazyColumn(modifier = modifier.fillMaxSize()) {
        items(
            items = viewModel.todoList,
            key = { it } // ใช้ key เพื่อให้เวลา Item หายไปตอนลบ Animation ของรายการอื่นจะดูสมูทขึ้น
        ) { todoItem ->
            TodoItemWithSwipeToDismiss(
                item = todoItem,
                onRemove = { viewModel.removeItem(todoItem) }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TodoItemWithSwipeToDismiss(item: String, onRemove: () -> Unit) {
    // กำหนด State สำหรับจำจดการเลื่อนไอเทม
    val dismissState = rememberSwipeToDismissBoxState(
        confirmValueChange = { dismissValue ->
            // ถ้าถึงจุดที่อนุญาตให้ปัด (End to Start) ทำการลบ
            if (dismissValue == SwipeToDismissBoxValue.EndToStart) {
                onRemove()
                true
            } else {
                false
            }
        }
    )

    // 2. ใช้ SwipeToDismissBox จาก Material 3
    SwipeToDismissBox(
        state = dismissState,
        // เปิดให้ปัดจากขวาไปซ้ายได้อย่างเดียว
        enableDismissFromEndToStart = true,
        enableDismissFromStartToEnd = false,
        backgroundContent = {
            // 3. กำหนดพื้นหลังและไอคอน (สีแดง + ไอคอนถังขยะ)
            val color by animateColorAsState(
                targetValue = when (dismissState.targetValue) {
                    SwipeToDismissBoxValue.EndToStart -> Color.Red
                    else -> Color.LightGray // สีเริ่มต้นตอนยังไม่ปัดถึงเป้าหมาย
                },
                label = "backgroundColor"
            )
            
            // ขยายไอคอนเมื่อปัดถึงระยะ
            val scale by animateFloatAsState(
                targetValue = if (dismissState.targetValue == SwipeToDismissBoxValue.EndToStart) 1.2f else 1f,
                label = "iconScale"
            )

            Box(
                Modifier
                    .fillMaxSize()
                    .padding(horizontal = 16.dp, vertical = 8.dp)
                    .background(color, shape = CardDefaults.shape)
                    .padding(horizontal = 20.dp),
                contentAlignment = Alignment.CenterEnd // จัดให้อยู่ขวา
            ) {
                Icon(
                    imageVector = Icons.Default.Delete,
                    contentDescription = "Delete Icon",
                    tint = Color.White,
                    modifier = Modifier.scale(scale)
                )
            }
        },
        content = {
            // กล่องข้อความ To-Do ที่จะแสดงอยู่หน้าสุด
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Text(
                    text = item,
                    modifier = Modifier.padding(24.dp),
                    style = MaterialTheme.typography.bodyLarge
                )
            }
        }
    )
}

@Preview(showBackground = true)
@Composable
fun TodoListPreview() {
    _167LabLearnAndroidTheme {
        TodoListScreen(viewModel = TodoViewModel())
    }
}