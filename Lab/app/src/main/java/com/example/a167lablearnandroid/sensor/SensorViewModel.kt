package com.example.a167lablearnandroid.sensor

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class SensorViewModel : ViewModel() {
    private val _sensorData = MutableStateFlow(SensorData())
    val sensorData: StateFlow<SensorData> = _sensorData.asStateFlow()

    fun updateSensorData(x: Float, y: Float, z: Float) {
        _sensorData.value = SensorData(x, y, z)
    }
}
