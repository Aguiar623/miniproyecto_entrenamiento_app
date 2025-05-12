import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:entrenamiento_app/database/database_helper.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'user_session.dart';


class StepCounterScreen extends StatefulWidget {
  @override
  _StepCounterScreenState createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  static const platform = MethodChannel('noti.steps');

  int _stepCount = 0;
  double _lastX = 0,
      _lastY = 0,
      _lastZ = 0;
  double _threshold = 1.2;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    accelerometerEventStream().listen((event) {
      double deltaX = (_lastX - event.x).abs();
      double deltaY = (_lastY - event.y).abs();
      double deltaZ = (_lastZ - event.z).abs();

      if (deltaX > _threshold || deltaY > _threshold || deltaZ > _threshold) {
        setState(() {
          _stepCount++;
        });
        if (_stepCount % 500 == 0){
           _sendStepNotification(_stepCount);
        }
      }
      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;
    });
  }

  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _sendStepNotification(int steps) async {
    try {
      await platform.invokeMethod('showNotification', {
        "message": "¡Has alcanzado $steps pasos!"
      });
    } catch (e) {
      print("Error al mostrar la notificación: $e");
    }
  }

  Future<void> _savedStepsAcount() async {
    try {
      print("guardando pasos: $_stepCount");
      await DatabaseHelper.instance.saveSteps(_stepCount, UserSession.currentUserId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pasos guardados en el historial.")),
      );
    } catch (e) {
      print("error al guardar pasos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contador de Pasos")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Pasos Contados:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "$_stepCount",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _stepCount = 0; // Reiniciar el contador
                });
              },
              child: Text("Reiniciar Contador"),
            ),
            SizedBox(height: 30),
            // Botón para guardar los pasos en la base de datos
            ElevatedButton(
              onPressed: _savedStepsAcount,
              child: Text("Guardar Pasos"),
            ),
          ],
        ),
      ),
    );
  }
}
