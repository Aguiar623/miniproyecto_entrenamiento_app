import 'package:flutter/material.dart';
import 'package:entrenamiento_app/database/database_helper.dart'; // Asegúrate de importar la clase DatabaseHelper
import 'user_session.dart';


class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _locationHistory = [];
  List<Map<String, dynamic>> _stepHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Cargar el historial de ubicaciones y pasos desde la base de datos
  Future<void> _loadHistory() async {
    var locations = await DatabaseHelper.instance.getLocationHistory(UserSession.currentUserId!);
    var steps = await DatabaseHelper.instance.getStepHistory(UserSession.currentUserId!);

    setState(() {
      _locationHistory = locations;
      _stepHistory = steps;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalSteps = _stepHistory.fold(0, (sum, item) => sum + ((item['steps'] ?? 0) as int));
    int totalLocations = _locationHistory.length;
    String? lastActivityDate = [
      ..._stepHistory.map((e) => e['timestamp']),
      ..._locationHistory.map((e) => e['timestamp'])
    ].isNotEmpty
        ? ([..._stepHistory, ..._locationHistory]
      ..sort((a, b) =>
          b['timestamp'].compareTo(a['timestamp'])))[0]['timestamp']
        : null;

    return Scaffold(
      appBar: AppBar(title: Text("Historial de Entrenamiento")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estadísticas generales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                      Icons.directions_walk, "Pasos Totales", "$totalSteps"),
                  _buildStatCard(
                      Icons.location_on, "Ubicaciones", "$totalLocations"),
                  _buildStatCard(Icons.calendar_today, "Última actividad",
                      lastActivityDate ?? "-"),
                ],
              ),
              SizedBox(height: 24),

              // Historial de ubicaciones
              Text("Historial de Ubicaciones",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _locationHistory.isEmpty
                  ? Padding(padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("No se han registrado ubicaciones."))
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _locationHistory.length,
                itemBuilder: (context, index) {
                  var loc = _locationHistory[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.place, color: Colors.blue),
                      title: Text("Ubicación ${index + 1}"),
                      subtitle: Text(
                          "Lat: ${loc['latitude']}, Lng: ${loc['longitude']}"),
                      trailing: Text(loc['timestamp'] ?? ''),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),
              // Historial de pasos
              Text("Historial de Pasos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _stepHistory.isEmpty
                  ? Padding(padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("No se han registrado pasos."))
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _stepHistory.length,
                itemBuilder: (context, index) {
                  var step = _stepHistory[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.directions_walk, color: Colors.green),
                      title: Text("Registro ${index + 1}"),
                      subtitle: Text("Pasos: ${step['steps']}"),
                      trailing: Text(step['timestamp'] ?? ''),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.teal),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
