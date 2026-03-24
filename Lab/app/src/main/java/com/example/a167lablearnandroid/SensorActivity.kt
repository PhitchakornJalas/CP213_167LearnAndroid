package com.example.a167lablearnandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.a167lablearnandroid.sensor.SensorTracker
import com.example.a167lablearnandroid.sensor.SensorViewModel

class SensorActivity : ComponentActivity() {

    private val sensorViewModel: SensorViewModel by viewModels()
    private lateinit var sensorTracker: SensorTracker

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        sensorTracker = SensorTracker(this) { x, y, z ->
            sensorViewModel.updateSensorData(x, y, z)
        }

        enableEdgeToEdge()
        setContent {
            Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                SensorScreen(
                    viewModel = sensorViewModel,
                    modifier = Modifier.padding(innerPadding)
                )
            }
        }
    }

    override fun onResume() {
        super.onResume()
        sensorTracker.startTracking()
    }

    override fun onPause() {
        super.onPause()
        sensorTracker.stopTracking()
    }
}

@Composable
fun SensorScreen(viewModel: SensorViewModel, modifier: Modifier = Modifier) {
    val sensorData by viewModel.sensorData.collectAsState()

    Column(
        modifier = modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Accelerometer Data", 
            fontSize = 26.sp, 
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 24.dp)
        )
        Text(text = "X: ${"%.2f".format(sensorData.x)}", fontSize = 20.sp, modifier = Modifier.padding(4.dp))
        Text(text = "Y: ${"%.2f".format(sensorData.y)}", fontSize = 20.sp, modifier = Modifier.padding(4.dp))
        Text(text = "Z: ${"%.2f".format(sensorData.z)}", fontSize = 20.sp, modifier = Modifier.padding(4.dp))
    }
}
