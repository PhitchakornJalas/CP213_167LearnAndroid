package com.example.a167lablearnandroid.sensor

import org.junit.Assert.assertEquals
import org.junit.Test

class SensorViewModelTest {
    @Test
    fun `initial state should be zero`() {
        val viewModel = SensorViewModel()
        val data = viewModel.sensorData.value
        
        assertEquals(0f, data.x, 0.0f)
        assertEquals(0f, data.y, 0.0f)
        assertEquals(0f, data.z, 0.0f)
    }

    @Test
    fun `updateSensorData updates the state flow`() {
        val viewModel = SensorViewModel()
        
        viewModel.updateSensorData(2.5f, -1.0f, 9.8f)
        val data = viewModel.sensorData.value
        
        assertEquals(2.5f, data.x, 0.0f)
        assertEquals(-1.0f, data.y, 0.0f)
        assertEquals(9.8f, data.z, 0.0f)
    }
}
