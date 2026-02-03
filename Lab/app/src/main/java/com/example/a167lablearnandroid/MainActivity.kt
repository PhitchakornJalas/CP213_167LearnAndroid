package com.example.a167lablearnandroid

import android.content.Intent
import android.media.Image
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        enableEdgeToEdge()
        setContent {
            RPGCardView()

        }
    }

    @Composable
    fun RPGCardView() {
        Column(modifier = Modifier
            .fillMaxSize()
            .background(Color.Gray)
            .padding(32.dp)) {

            // hp
            Box(modifier = Modifier
                .fillMaxWidth()
                .height(32.dp)
                .background(Color.White)) {
                Text(
                    text = "hp",
                    color = Color.White,
                    modifier = Modifier
                        .align(alignment = Alignment.CenterStart)
                        .fillMaxWidth(fraction = 0.67f)
                        .background(Color.Red)
                        .padding(8.dp)
                )
            }

            // image
            Image(
                painter = painterResource(id = R.drawable.wei),
                contentDescription = "Profile",
                modifier = Modifier
                    .align(Alignment.CenterHorizontally)
                    .padding(top = 16.dp, bottom = 32.dp)
                    .clickable {
                        startActivity((Intent(this@MainActivity, ListActivity::class.java)))
                    }
            )

            var status1 by remember { mutableStateOf(99) }
            var status2 by remember { mutableStateOf(99) }
            var status3 by remember { mutableStateOf(99) }
            // status
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Button(onClick = {
                        status1++
                    }) {
//                    Image(
//                        painter = painterResource(id = R.drawable.baseline_thumb_up_24)
//                        contentDescription = "Profile"
//                    )
                    }
                    Text(text = "หล่อ", fontSize = 32.sp)
                    Text(text = status1.toString(), fontSize = 32.sp)
                    Text(text = "-", fontSize = 32.sp,
                        modifier = Modifier.clickable {
                            status1--
                        })
                }
                Column {
                    Text(text = "+", fontSize = 32.sp)
                    Text(text = "น่ารัก", fontSize = 32.sp)
                    Text(text = status2.toString(), fontSize = 32.sp)
                    Text(text = "-", fontSize = 32.sp)
                }
                Column {
                    Text(text = "+", fontSize = 32.sp)
                    Text(text = "ขี้เล่น", fontSize = 32.sp)
                    Text(text = status3.toString(), fontSize = 32.sp)
                    Text(text = "-", fontSize = 32.sp)
                }
            }
        }
    }
}

//@Preview
//@Composable
//fun previewScreen() {
//    RPGCardView()
//}