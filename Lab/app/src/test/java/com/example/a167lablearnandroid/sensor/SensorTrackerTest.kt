package com.example.a167lablearnandroid.sensor

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorManager
import io.mockk.every
import io.mockk.mockk
import io.mockk.unmockkAll
import io.mockk.verify
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import java.lang.reflect.Field

class SensorTrackerTest {

    private lateinit var context: Context
    private lateinit var sensorManager: SensorManager
    private lateinit var accelerometer: Sensor
    private lateinit var sensorTracker: SensorTracker
    
    private var callbackInvoked = false
    private var capturedX = 0f
    private var capturedY = 0f
    private var capturedZ = 0f

    @Before
    fun setUp() {
        context = mockk()
        sensorManager = mockk(relaxed = true)
        accelerometer = mockk()

        every { context.getSystemService(Context.SENSOR_SERVICE) } returns sensorManager
        every { sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) } returns accelerometer

        sensorTracker = SensorTracker(context) { x, y, z ->
            callbackInvoked = true
            capturedX = x
            capturedY = y
            capturedZ = z
        }
        callbackInvoked = false
    }

    @After
    fun tearDown() {
        unmockkAll()
    }

    @Test
    fun `startTracking registers listener`() {
        sensorTracker.startTracking()
        verify { sensorManager.registerListener(sensorTracker, accelerometer, SensorManager.SENSOR_DELAY_UI) }
    }

    @Test
    fun `stopTracking unregisters listener`() {
        sensorTracker.stopTracking()
        verify { sensorManager.unregisterListener(sensorTracker) }
    }

    @Test
    fun `onSensorChanged triggers callback for ACCELEROMETER`() {
        val event = createSensorEvent(floatArrayOf(1.5f, 2.5f, 3.5f), Sensor.TYPE_ACCELEROMETER)
        
        sensorTracker.onSensorChanged(event)
        
        assertTrue(callbackInvoked)
        assertEquals(1.5f, capturedX, 0.0f)
        assertEquals(2.5f, capturedY, 0.0f)
        assertEquals(3.5f, capturedZ, 0.0f)
    }

    @Test
    fun `onSensorChanged does nothing for other sensors`() {
        val event = createSensorEvent(floatArrayOf(1.5f, 2.5f, 3.5f), Sensor.TYPE_GYROSCOPE)
        
        sensorTracker.onSensorChanged(event)
        
        assertTrue(!callbackInvoked)
    }

    private fun createSensorEvent(values: FloatArray, type: Int): SensorEvent {
        val constructor = SensorEvent::class.java.declaredConstructors.first()
        constructor.isAccessible = true
        val event = if (constructor.parameterTypes.size == 1) {
            constructor.newInstance(values.size) as SensorEvent
        } else {
            constructor.newInstance() as SensorEvent
        }
        
        val sensor = mockk<Sensor>()
        every { sensor.type } returns type
        
        try {
            val sensorField = SensorEvent::class.java.getField("sensor")
            sensorField.isAccessible = true
            sensorField.set(event, sensor)
        } catch (e: Exception) {
            event.sensor = sensor
        }
        
        try {
            val valuesField = SensorEvent::class.java.getField("values")
            valuesField.isAccessible = true
            valuesField.set(event, values)
        } catch (e: Exception) {
            if (event.values != null && event.values.size >= values.size) {
                System.arraycopy(values, 0, event.values, 0, values.size)
            }
        }
        
        return event
    }
}
