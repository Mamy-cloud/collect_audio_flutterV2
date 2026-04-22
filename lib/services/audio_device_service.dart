// audio_device_service.dart
// Communique avec MainActivity.kt via MethodChannel
// pour lister les micros disponibles

import 'package:flutter/services.dart';

class AudioDevice {
  final int    id;
  final String name;
  final int    type;

  const AudioDevice({
    required this.id,
    required this.name,
    required this.type,
  });

  bool get isBuiltIn  => type == 15;        // TYPE_BUILTIN_MIC
  bool get isUsb      => type == 26 || type == 28; // USB_DEVICE / USB_HEADSET
  bool get isWired    => type == 4;         // WIRED_HEADSET
  bool get isBluetooth => type == 7;        // BLUETOOTH_SCO

  @override
  String toString() => name;
}

class AudioDeviceService {
  static const _channel =
      MethodChannel('com.example.collect_audio_flutter/audio_device');

  static Future<List<AudioDevice>> getInputDevices() async {
    try {
      final List<dynamic> result =
          await _channel.invokeMethod('getInputDevices');

      return result.map((d) {
        final map = Map<String, dynamic>.from(d as Map);
        return AudioDevice(
          id:   map['id']   as int,
          name: map['name'] as String,
          type: map['type'] as int,
        );
      }).toList();
    } catch (e) {
      return [const AudioDevice(id: 0, name: 'Micro par défaut', type: 0)];
    }
  }
}
