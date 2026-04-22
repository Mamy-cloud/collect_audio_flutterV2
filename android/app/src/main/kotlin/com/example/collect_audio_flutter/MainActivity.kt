package com.example.collect_audio_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.AudioManager
import android.media.AudioDeviceInfo
import android.media.AudioRecord
import android.content.Context
import android.os.Build

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.collect_audio_flutter/audio_device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // ── Liste les appareils audio disponibles ─────────────
                    "getInputDevices" -> {
                        try {
                            result.success(getAvailableInputDevices())
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun getAvailableInputDevices(): List<Map<String, Any>> {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val devices      = mutableListOf<Map<String, Any>>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val inputDevices = audioManager.getDevices(AudioManager.GET_DEVICES_INPUTS)

            for (device in inputDevices) {
                val type = device.type
                if (type == AudioDeviceInfo.TYPE_BUILTIN_MIC   ||
                    type == AudioDeviceInfo.TYPE_USB_DEVICE    ||
                    type == AudioDeviceInfo.TYPE_USB_HEADSET   ||
                    type == AudioDeviceInfo.TYPE_WIRED_HEADSET ||
                    type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO) {

                    devices.add(mapOf(
                        "id"   to device.id,
                        "name" to getDeviceName(type),
                        "type" to type,
                    ))
                }
            }
        }

        // Micro par défaut si aucun trouvé
        if (devices.isEmpty()) {
            devices.add(mapOf(
                "id"   to 0,
                "name" to "Micro par défaut",
                "type" to 0,
            ))
        }

        return devices
    }

    private fun getDeviceName(type: Int): String {
        return when (type) {
            AudioDeviceInfo.TYPE_BUILTIN_MIC   -> "Micro intégré"
            AudioDeviceInfo.TYPE_USB_DEVICE    -> "USB-C"
            AudioDeviceInfo.TYPE_USB_HEADSET   -> "Casque USB-C"
            AudioDeviceInfo.TYPE_WIRED_HEADSET -> "Casque filaire"
            AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> "Bluetooth"
            else                               -> "Micro inconnu"
        }
    }
}
