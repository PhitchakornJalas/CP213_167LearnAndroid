package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

// 1. สร้าง ViewModel จัดการ State ของรายชื่อผู้ติดต่อ และสถานะการโหลด
class ContactListViewModel : ViewModel() {
    private val _contacts = MutableStateFlow<List<String>>(emptyList())
    val contacts: StateFlow<List<String>> = _contacts.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private var currentPage = 0

    init {
        loadMoreContacts() // โหลดข้อมูลชุดแรก
    }

    // 3. ฟังก์ชันจำลองการโหลดข้อมูลเพิ่ม (Pagination)
    fun loadMoreContacts() {
        if (_isLoading.value) return // ป้องกันการโหลดซ้ำถ้ายกกำลังโหลดอยู่

        viewModelScope.launch {
            _isLoading.value = true
            
            // จำลองการใช้เวลาโหลดข้อมูลจาก Network 2 วินาที
            delay(2000)

            val newContacts = generateMockContacts(currentPage)
            // อัปเดตข้อมูลใหม่ต่อท้ายของเดิม
            _contacts.value = _contacts.value + newContacts
            
            if (newContacts.isNotEmpty()) {
                currentPage++
            }
            
            _isLoading.value = false
        }
    }

    // สร้าง Mock Data เป็นตัวอักษรเรียงไปเรื่อยๆ เพื่อให้เกิด Scroll และ Pagination 
    private fun generateMockContacts(page: Int): List<String> {
        val allLetters = ('A'..'Z').toList()
        val startIndex = page * 5
        if (startIndex >= allLetters.size) return emptyList()

        val endIndex = minOf(startIndex + 5, allLetters.size)
        val lettersForPage = allLetters.subList(startIndex, endIndex)

        val names = mutableListOf<String>()
        for (letter in lettersForPage) {
            for (i in 1..4) { // สมมติว่าแต่ละตัวอักษรมีคน 4 คน
                names.add("$letter - Contact Name $i (Page ${page + 1})")
            }
        }
        return names
    }
}

class Part2ComplexListsPaginationActivity : ComponentActivity() {
    private val viewModel: ContactListViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            _167LabLearnAndroidTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    ContactListScreen(
                        viewModel = viewModel,
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun ContactListScreen(viewModel: ContactListViewModel, modifier: Modifier = Modifier) {
    val contacts by viewModel.contacts.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()

    val listState = rememberLazyListState()

    // สังเกตว่า Scroll มาถึงเกือบสุดรายการหรือยัง (เหลือ 2 รายการสุดท้าย)
    val shouldLoadMore by remember {
        derivedStateOf {
            val totalItemsCount = listState.layoutInfo.totalItemsCount
            val lastVisibleItemIndex = listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0
            
            totalItemsCount > 0 && lastVisibleItemIndex >= totalItemsCount - 2
        }
    }

    // ถ้าควรโหลดเพิ่ม ให้ Trigger ไปที่ ViewModel
    LaunchedEffect(shouldLoadMore) {
        if (shouldLoadMore && !isLoading) {
            viewModel.loadMoreContacts()
        }
    }

    // จัดกลุ่มรายชื่อตามตัวอักษรตัวแรก เพื่อไปทำ Sticky Header
    val groupedContacts = contacts.groupBy { it.first().uppercase() }

    LazyColumn(
        state = listState,
        modifier = modifier.fillMaxSize()
    ) {
        groupedContacts.forEach { (initial, contactsForInitial) ->
            // 2. ใช้ stickyHeader สำหรับตัวอักษรนำหน้า (A, B, C...)
            stickyHeader {
                Text(
                    text = initial,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onPrimaryContainer,
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(MaterialTheme.colorScheme.primaryContainer)
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                )
            }

            // แสดงรายชื่อคนในตัวอักษรนั้นๆ
            items(contactsForInitial) { contact ->
                Text(
                    text = contact,
                    style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 12.dp)
                )
            }
        }

        // 4. แสดง CircularProgressIndicator ที่ด้านล่างสุด ขณะโหลดข้อมูล
        if (isLoading) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }
        }
    }
}