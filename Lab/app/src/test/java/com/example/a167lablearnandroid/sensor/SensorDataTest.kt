package com.example.a167lablearnandroid.sensor

import org.junit.Assert.assertEquals
import org.junit.Test

class SensorDataTest {
//    @Test
//    fun `test default values are zero`() {
//
//    }

    @Test
    fun `test custom values are assigned correctly`() {
        val data = SensorData(1f, 2f, 3f)
        assertEquals(1f, data.x, 0.0f)
        assertEquals(2f, data.y, 0.0f)
        assertEquals(3f, data.z, 0.0f)
    }
}
