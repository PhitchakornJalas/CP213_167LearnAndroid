package com.example.a167lablearnandroid

import android.content.Intent
import android.media.Image
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonColors
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Alignment.Companion
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        enableEdgeToEdge()
        Log.i("Lifecycle", "MainActivity : onCreate")
        setContent {
            RPGCardView()
            previewScreen()
        }
    }

    override fun onStart() {
        super.onStart()
        Log.i("Lifecycle", "MainActivity : onStart")
    }

    override fun onResume() {
        super.onResume()
        Log.i("Lifecycle", "MainActivity : onResume")
    }

    override fun onPause() {
        super.onPause()
        Log.i("Lifecycle", "MainActivity : onPause")
    }

    override fun onStop() {
        super.onStop()
        Log.i("Lifecycle", "MainActivity : onStop")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.i("Lifecycle", "MainActivity : onDestroy")
    }

    override fun onRestart() {
        super.onRestart()
        Log.i("Lifecycle", "MainActivity : onRestart")
    }

    @Composable
    fun RPGCardView() {
        Column(modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .padding(32.dp),
            verticalArrangement = Arrangement.Center) {

            // hp
            Box(modifier = Modifier
                .fillMaxWidth()
                .height(32.dp)
                .background(Color.White)
                .border(
                    width = 2.dp, color = Color.Black)
            ) {
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
                    .padding(top = 64.dp, bottom = 64.dp)
                    .clip(RoundedCornerShape(16.dp)
                )
                    .clickable {
//                        startActivity((Intent(this@MainActivity, ListActivity::class.java)))
//                        startActivity((Intent(this@MainActivity, MainActivity2::class.java)))
                    }
            )

            var status1 by remember { mutableStateOf(1) }
            var status2 by remember { mutableStateOf(1) }
            var status3 by remember { mutableStateOf(99) }
            // status
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column(
                    modifier = Modifier
                        .width(100.dp),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(text = "หล่อ", fontSize = 32.sp,
                        modifier = Modifier
                    )
                    Text(text = status1.toString(), fontSize = 32.sp)
                    Row {
                        Button(onClick = { status1++ },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color.Transparent
                            ),
                            contentPadding = PaddingValues(0.dp),
                            modifier = Modifier
                                .width(50.dp)
                        ) {
                            Image(
                                painter = painterResource(id = R.drawable.round_thumb_up_24),
                                contentDescription = "thumbUp",
                                modifier = Modifier
                                    .size(32.dp)
                            )
                        }

                        Button(onClick = { status1-- },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color.Transparent
                            ),
                            contentPadding = PaddingValues(0.dp),
                            modifier = Modifier
                                .width(50.dp)
                        ) {
                            Image(
                                painter = painterResource(id = R.drawable.round_thumb_down_24),
                                contentDescription = "thumbDown",
                                modifier = Modifier
                                    .size(32.dp)
                            )
                        }
                    }
                }
                Column(
                    modifier = Modifier
                        .width(100.dp),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(text = "น่ารัก", fontSize = 32.sp)
                    Text(text = status2.toString(), fontSize = 32.sp)
                    Row {
                        Button(onClick = { status2++ },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color.Transparent
                            ),
                            contentPadding = PaddingValues(0.dp),
                            modifier = Modifier
                                .width(50.dp)
                        ) {
                            Image(
                                painter = painterResource(id = R.drawable.round_thumb_up_24),
                                contentDescription = "thumbUp",
                            )
                        }

                        Button(onClick = { status2-- },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color.Transparent
                            ),
                            contentPadding = PaddingValues(0.dp),
                            modifier = Modifier
                                .width(50.dp)
                        ) {
                            Image(
                                painter = painterResource(id = R.drawable.round_thumb_down_24),
                                contentDescription = "thumbDown",
                                modifier = Modifier
                                    .size(32.dp)
                            )
                        }
                    }
                }
                Column(
                    modifier = Modifier
                        .width(100.dp),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(text = "เต้น", fontSize = 32.sp)
                    Text(text = status3.toString(), fontSize = 32.sp)
                    Row {
                        Button(onClick = { status3++ },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color.Transparent
                            ),
                            contentPadding = PaddingValues(0.dp),
                            modifier = Modifier
                                .width(50.dp)
                        ) {
                            Image(
                                painter = painterResource(id = R.drawable.round_thumb_up_24),
                                contentDescription = "thumbUp",
                                modifier = Modifier
                                    .size(32.dp)
                            )
                        }

                        Button(onClick = { status3-- },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color.Transparent
                            ),
                            contentPadding = PaddingValues(0.dp),
                            modifier = Modifier
                                .width(50.dp)
                        ) {
                            Image(
                                painter = painterResource(id = R.drawable.round_thumb_down_24),
                                contentDescription = "thumbDown",
                                modifier = Modifier
                                    .size(32.dp)
                            )
                        }
                    }
                }
            }
        }
    }

    @Preview
    @Composable
    fun previewScreen() {
        RPGCardView()
    }

}
