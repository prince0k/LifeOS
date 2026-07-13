package com.lifeos.lifeos

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity: FlutterActivity(), SensorEventListener {
    private val USAGE_CHANNEL = "com.lifeos.lifeos/usage"
    private val PEDOMETER_CHANNEL = "com.lifeos.lifeos/pedometer"
    private var sensorManager: SensorManager? = null
    private var stepCounterSensor: Sensor? = null
    private var stepsSinceBoot: Float = 0f

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepCounterSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        if (stepCounterSensor != null) {
            sensorManager?.registerListener(this, stepCounterSensor, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 1. Usage stats channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsagePermission" -> {
                    result.success(checkUsagePermission())
                }
                "grantUsagePermission" -> {
                    grantUsagePermission()
                    result.success(null)
                }
                "getScreenTimeMinutes" -> {
                    result.success(getScreenTimeMinutes())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // 2. Pedometer channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PEDOMETER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStepsSinceBoot" -> {
                    result.success(stepsSinceBoot.toInt())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun grantUsagePermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun getScreenTimeMinutes(): Int {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val cal = Calendar.getInstance()
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        val startTime = cal.timeInMillis

        val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
        var totalTimeMs: Long = 0
        if (stats != null) {
            for (usageStats in stats) {
                totalTimeMs += usageStats.totalTimeInForeground
            }
        }
        return (totalTimeMs / 1000 / 60).toInt()
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER) {
            stepsSinceBoot = event.values[0]
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
