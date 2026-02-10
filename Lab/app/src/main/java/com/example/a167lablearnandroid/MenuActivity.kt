package com.example.a167lablearnandroid

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class MenuActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            Column(modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)) {
                Button(onClick = {
                    startActivity((Intent(this@MenuActivity, MainActivity::class.java)))
                }) {
                    Text("RPGCaardActivity")
                }
                Button(onClick = {
                    startActivity((Intent(this@MenuActivity, ListActivity::class.java)))
                }) {
                    Text("Pokemon")
                }
                Button(onClick = {
                    startActivity((Intent(this@MenuActivity, MainActivity2::class.java)))
                }) {
                    Text("LifeCycleComposeActivity")
                }
            }
        }
    }
}